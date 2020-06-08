//
//  WebSocketHandler.swift
//  ios
//
//  Created by Alexey Liverty on 6/8/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation
import NIO
import NIOWebSocket

class WebSocketHandler: ChannelInboundHandler {
    typealias InboundIn = WebSocketFrame
    typealias OutboundOut = WebSocketFrame
    
    private let mutex: DispatchSemaphore
    private let callbacks: WebSocketCallbacks
    private let wsRegistry: WebSocketRegistry
    private let serverRunning: WiltonBoolRef
    
    init(_ mutex: DispatchSemaphore, _ callbacks: WebSocketCallbacks, _ wsRegistry: WebSocketRegistry,
         _ serverRunning: WiltonBoolRef, _ channel: Channel) {
        self.mutex = mutex
        self.callbacks = callbacks
        self.wsRegistry = wsRegistry
        self.serverRunning = serverRunning
        
        wsRegistry.addChannel(channel)
        onOpen(channel)
    }
        
    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let frame = unwrapInboundIn(data)
            
        switch frame.opcode {
        case .connectionClose:
            onClose(context, context.channel, frame)
        case .ping:
            onPing(context.channel, frame)
        case .text:
            onMessage(context.channel, frame)
        case .binary, .continuation, .pong:
            // ignore these frames
            break
        default:
            // ignore unknown frames
            break
        }
    }
    
    public func channelInactive(context: ChannelHandlerContext) {
        wsRegistry.removeChannel(context.channel)
    }
    
    private func onOpen(_ channel: Channel) {
        guard let cb = callbacks.onOpen else {
            return
        }
        let resp = runOnJsThreadSync(cb)
        sendResponse(channel, resp)
    }
    
    private func onMessage(_ channel: Channel, _ frame: WebSocketFrame) {
        guard let om = callbacks.onMessage else {
            return
        }
        var data = frame.unmaskedData
        let message = data.readString(length: data.readableBytes) ?? "{}"
        let cb = JSCoreScript(om.module, om.func_, [message])
        let resp = runOnJsThreadSync(cb)
        sendResponse(channel, resp)
    }

    private func onClose(_ context: ChannelHandlerContext, _ channel: Channel, _ frame: WebSocketFrame) {
        // This is an unsolicited close. We're going to send a response frame and
        // then, when we've sent it, close up shop. We should send back the close code the remote
        // peer sent us, unless they didn't send one at all.
        wsRegistry.removeChannel(channel)
        var data = frame.unmaskedData
        let closeDataCode = data.readSlice(length: 2) ?? channel.allocator.buffer(capacity: 0)
        let closeFrame = WebSocketFrame(fin: true, opcode: .connectionClose, data: closeDataCode)
        _ = channel.writeAndFlush(self.wrapOutboundOut(closeFrame)).map {
            context.close(promise: nil)
        }
        guard let cb = callbacks.onClose else {
            return
        }
        let resp = runOnJsThreadSync(cb)
        sendResponse(channel, resp)
    }
        
    private func onPing(_ channel: Channel, _ frame: WebSocketFrame) {
        var frameData = frame.data
        let maskingKey = frame.maskKey
        if let maskingKey = maskingKey {
            frameData.webSocketUnmask(maskingKey)
        }
        let responseFrame = WebSocketFrame(fin: true, opcode: .pong, data: frameData)
        channel.writeAndFlush(self.wrapOutboundOut(responseFrame), promise: nil)
    }
    
    private func sendResponse(_ channel: Channel, _ resp: String) {
        if !resp.isEmpty {
            withExtendedLifetime(WiltonDispatchGuard(mutex)) {
                if !serverRunning.get() {
                    return
                }
                sendWebSocket(channel, resp)
            }
        }
    }
}
