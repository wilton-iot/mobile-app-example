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
    private let wsRegistry: WebSocketRegistry
    
    init(_ wsRegistry: WebSocketRegistry) {
        self.wsRegistry = wsRegistry
    }
        
    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let frame = self.unwrapInboundIn(data)
            
        switch frame.opcode {
        case .connectionClose:
            self.receivedClose(context: context, frame: frame)
        case .ping:
            self.pong(context: context, frame: frame)
        case .text:
            var data = frame.unmaskedData
            let text = data.readString(length: data.readableBytes) ?? "{}"
            handleCallAsync(context: context, req: text)
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
    
    private func handleCallAsync(context: ChannelHandlerContext, req: String) {
        //print("--- WS incoming req: ", req)
        /*
        let chan = context.channel
        if let queue = self.server.getJsQueue() {
            queue.async(flags: .barrier) {
                // call handler
                let msg = self.server.handleCallJs(req);
                // send response back
                withExtendedLifetime(DispatchGuard(self.server.mutex)) {
                    // check whether we can send
                    if !self.server.isRunningUnsafe() {
                        return
                    }
                    sendWebSocket(chan, msg)
                }
            }
        }
        */
        // TODO
    }

    private func receivedClose(context: ChannelHandlerContext, frame: WebSocketFrame) {
        // This is an unsolicited close. We're going to send a response frame and
        // then, when we've sent it, close up shop. We should send back the close code the remote
        // peer sent us, unless they didn't send one at all.
        wsRegistry.removeChannel(context.channel)
        var data = frame.unmaskedData
        let closeDataCode = data.readSlice(length: 2) ?? context.channel.allocator.buffer(capacity: 0)
        let closeFrame = WebSocketFrame(fin: true, opcode: .connectionClose, data: closeDataCode)
        _ = context.writeAndFlush(self.wrapOutboundOut(closeFrame)).map {
            context.close(promise: nil)
        }
    }
        
    private func pong(context: ChannelHandlerContext, frame: WebSocketFrame) {
        var frameData = frame.data
        let maskingKey = frame.maskKey
        if let maskingKey = maskingKey {
            frameData.webSocketUnmask(maskingKey)
        }
        let responseFrame = WebSocketFrame(fin: true, opcode: .pong, data: frameData)
        context.writeAndFlush(self.wrapOutboundOut(responseFrame), promise: nil)
    }
}
