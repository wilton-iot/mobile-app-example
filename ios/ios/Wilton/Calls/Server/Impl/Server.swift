//
//  Server.swift
//  ios
//
//  Created by Alexey Liverty on 6/8/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation
import NIO
import NIOHTTP1
import NIOWebSocket

class Server {
    private let mutex = DispatchSemaphore(value: 1)
    private let loopGroup: MultiThreadedEventLoopGroup
    private let wsRegistry: WebSocketRegistry
    private let serverChannel: Channel
    private var running: WiltonBoolRef = WiltonBoolRef(true)
    
    init(_ hostname: String, _ port: Int, _ droots: [DocumentRoot],
         _ callbacks: WebSocketCallbacks, _ httpPostHandler: JSCoreScript?) throws {
        
        loopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        wsRegistry = WebSocketRegistry(mutex)
        let upgrader = createUpgrader(mutex, callbacks, wsRegistry, running)
        let bootstrap = ServerBootstrap(group: loopGroup)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .childChannelInitializer { channel in
                let httpHandler = HTTPHandler()
                let config = createUpgradeConfig(upgrader, channel, httpHandler)
                return channel.pipeline.configureHTTPServerPipeline(withServerUpgrade: config).flatMap {
                    channel.pipeline.addHandler(httpHandler)
                }
            }
            .childChannelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
            .childChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 1)
        do {
            serverChannel = try bootstrap.bind(host: hostname, port: port).wait()
        } catch {
            throw WiltonException("Server/Server: Error starting server, message: [\(error)]")
        }
    }
    
    func broadcastWebSocket(_ message: String) {
        withExtendedLifetime(WiltonDispatchGuard(mutex)) {
            if !self.running.get() {
                return
            }
            for chan in wsRegistry.channels() {
                sendWebSocket(chan, message)
            }
        }
    }
    
    func getListeningPort() -> Int {
        return serverChannel.localAddress?.port ?? -1
    }
    
    func stop() {
        // switch state to stopped
        let canStop = withExtendedLifetime(WiltonDispatchGuard(mutex)) { () -> Bool in
            let res = self.running.get()
            running.set(false)
            return res
        }
        
        // check already stopped
        if !canStop {
            return
        }
        
        // stop server
        serverChannel.close().whenComplete { result in
            switch result {
            case .failure(let error):
                print("Server/Server: Failed to stop server channel: \(error)")
            case .success:
                self.loopGroup.shutdownGracefully { error in
                    if let error = error {
                        print("Server/Server: Failed to stop server loop group: \(error)")
                    }
                }
            }
        }
    }
}

func sendWebSocket(_ channel: Channel, _ msg: String) {
    if !channel.isActive {
        return
    }
    var buffer = channel.allocator.buffer(capacity: msg.count)
    buffer.writeString(msg)
    let frame = WebSocketFrame(fin: true, opcode: .text, data: buffer)
    // channel is thread-safe
    _ = channel.writeAndFlush(frame)
}

fileprivate func createUpgrader(_ mutex: DispatchSemaphore, _ callbacks: WebSocketCallbacks,
                                _ wsRegistry: WebSocketRegistry, _ running: WiltonBoolRef) -> NIOWebSocketServerUpgrader {
    return NIOWebSocketServerUpgrader(shouldUpgrade: { (channel: Channel, head: HTTPRequestHead) in
        channel.eventLoop.makeSucceededFuture(HTTPHeaders())
    }, upgradePipelineHandler: { (channel: Channel, _: HTTPRequestHead) in
        let handler = WebSocketHandler(mutex, callbacks, wsRegistry, running, channel)
        return channel.pipeline.addHandler(handler)
    })
}

fileprivate func createUpgradeConfig(_ upgrader: NIOWebSocketServerUpgrader, _ channel: Channel,
                         _ httpHandler: HTTPHandler) -> NIOHTTPServerUpgradeConfiguration {
    return NIOHTTPServerUpgradeConfiguration(
        upgraders: [ upgrader ],
        completionHandler: { _ in
            channel.pipeline.removeHandler(httpHandler, promise: nil)
        }
    )
}
