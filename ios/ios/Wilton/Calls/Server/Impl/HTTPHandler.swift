//
//  HTTPHandler.swift
//  ios
//
//  Created by Alexey Liverty on 6/8/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation
import NIO
import NIOHTTP1

class HTTPHandler : ChannelInboundHandler, RemovableChannelHandler {
    typealias InboundIn = HTTPServerRequestPart
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let reqPart = self.unwrapInboundIn(data)
        switch reqPart {
        case .head(let request):
            if request.uri.hasPrefix("/web/") {
                handleWeb(context.channel, request);
            } else if request.uri.hasPrefix("/api/") {
                handleApi(context.channel, request);
            } else {
                handle404(context.channel, request);
            }
            let endpart = HTTPServerResponsePart.end(nil)
            _ = context.channel.writeAndFlush(endpart).whenComplete { _ in
                if !request.isKeepAlive {
                    _ = context.close(promise: nil)
                }
                // `AllowRemoteHalfClosureOption` allows users to configure whether the `Channel` will close itself when its remote
                // peer shuts down its send stream, or whether it will remain open. If set to `false` (the default), the `Channel`
                // will be closed automatically if the remote peer shuts down its send stream.
            }
        // ignore incoming content
        case .body, .end: break
        }
    }
    
    private func handleWeb(_ chan: Channel, _ req: HTTPRequestHead) {
        let reqPathNoSlash = String(req.uri.suffix(req.uri.count - 1));
        /*
        let file = server.resourcesPath.appendingPathComponent(reqPathNoSlash, isDirectory: false);
        if FileManager.default.isReadableFile(atPath: file.path) {
            let bytes = readFile(file)
            let head = createRespHeadPart(req, file)
            _ = chan.write(head)
            let body = createRespBodyPart(req, chan.allocator, bytes)
            _ = chan.write(body)
        } else {
            handle404(chan, req)
        }
        */
        // TODO
        handle404(chan, req)
    }

    private func handleApi(_ chan: Channel, _ req: HTTPRequestHead) {
        let uri = req.uri;
        // TODO
        handle404(chan, req)
    }

    private func handle404(_ chan: Channel, _ req: HTTPRequestHead) {
        let head = HTTPResponseHead(version: req.version, status: .notFound)
        let part = HTTPServerResponsePart.head(head)
        _ = chan.write(part)
    }
    
    private func handle200(_ chan: Channel, _ req: HTTPRequestHead) {
        let head = HTTPResponseHead(version: req.version, status: .ok)
        let part = HTTPServerResponsePart.head(head)
        _ = chan.write(part)
    }
}
