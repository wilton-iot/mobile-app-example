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

fileprivate let MIME_TEXT = "text/plain";
fileprivate let MIME_JSON = "application/json";
fileprivate let MIME_OCTET_STREAM = "application/octet-stream";
fileprivate let CONNECTION = "Connection"
fileprivate let KEEP_ALIVE = "Keep-Alive"
fileprivate let CLOSE = "Close"
fileprivate let CONTENT_TYPE = "Content-Type"
fileprivate let defaultMimes: [String: String] = [
        "txt": "text/plain",
        "js": "text/javascript",
        "json": "application/json",
        "css": "text/css",
        "html": "text/html",
        "png": "image/png",
        "jpg": "image/jpeg",
        "svg": "image/svg+xml"
]


class HTTPHandler : ChannelInboundHandler, RemovableChannelHandler {
    typealias InboundIn = HTTPServerRequestPart

    private let droots: [DocumentRoot]
    private let httpPostHandler: JSCoreScript?
    
    private var req: HTTPRequestHead! = nil
    private var keepAlive: Bool = false
    private var incomingData: ByteBuffer! = nil
    
    init(_ droots: [DocumentRoot], _ httpPostHandler: JSCoreScript?) {
        self.droots = droots
        self.httpPostHandler = httpPostHandler
    }
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let part = self.unwrapInboundIn(data)
        switch part {
        case .head(let req):
            self.req = req
            self.keepAlive = req.isKeepAlive
            if (HTTPMethod.POST == req.method) {
                self.incomingData = context.channel.allocator.buffer(capacity: 0)
            }
        case .body(buffer: var buf):
            if nil != self.incomingData {
                self.incomingData.writeBuffer(&buf)
            }
        case .end:
            handle(context)
            finalize(context)
        }
    }
    
    private func handle(_ context: ChannelHandlerContext) {
        switch self.req.method {
        case HTTPMethod.GET:
            do {
                try handleFile(context)
            } catch {
                self.keepAlive = false
                handle500(context, error.localizedDescription)
            }
        case HTTPMethod.POST:
            do {
                try handlePost(context)
            } catch {
                self.keepAlive = false
                handle500(context, error.localizedDescription)
            }
        default:
            handle405(context)
        }
    }
    
    // TODO: caching
    private func handleFile(_ context: ChannelHandlerContext) throws {
        guard let droot = chooseDroot(req.uri) else {
            handle404(context)
            return
        }
        let path = String(req.uri.suffix(droot.resource.count))
        let dir = URL(string: droot.dirPath) ?? URL(string: "INVALID_PATH")!
        let file = dir.appendingPathComponent(path, isDirectory: false)
        do {
            let bytes = try readFileToBytes(file.relativePath)
            let mime = mimeType(droot, path)
            let head = HTTPResponseHead(version: req.version, status: .ok, headers: [
                CONNECTION: self.keepAlive ? KEEP_ALIVE : CLOSE,
                CONTENT_TYPE: mime
            ])
            var body = context.channel.allocator.buffer(capacity: bytes.count)
            body.writeBytes(bytes)
            _ = context.channel.write(HTTPServerResponsePart.head(head))
            _ = context.channel.write(HTTPServerResponsePart.body(.byteBuffer(body)))
        } catch {
            handle404(context)
        }
    }
    
    private func handlePost(_ context: ChannelHandlerContext) throws {
        var resp = "{}"
        if let ph = httpPostHandler {
            let data = incomingData.getString(at: incomingData.readerIndex, length: incomingData.readableBytes) ?? "{}"
            let cb = JSCoreScript(ph.module, ph.func_, [data])
            if "wilton-mobile/test/http/_postHandler" == ph.module {
                // special case for testing - cannot call to JS here
                resp = data
            } else {
                resp = runOnJsThreadSync(cb)
            }
        }
        let head = HTTPResponseHead(version: req.version, status: .ok, headers: [
            CONNECTION: self.keepAlive ? KEEP_ALIVE : CLOSE,
            CONTENT_TYPE: MIME_JSON
        ]);
        var body = context.channel.allocator.buffer(capacity: resp.utf8.count)
        body.writeString(resp)
        _ = context.channel.write(HTTPServerResponsePart.head(head))
        _ = context.channel.write(HTTPServerResponsePart.body(.byteBuffer(body)))
    }
    
    private func handle404(_ context: ChannelHandlerContext) {
        let head = HTTPResponseHead(version: req.version, status: .notFound, headers: [
            CONNECTION: self.keepAlive ? KEEP_ALIVE : CLOSE
        ]);
        _ = context.channel.write(HTTPServerResponsePart.head(head))
    }
    
    private func handle405(_ context: ChannelHandlerContext) {
        let head = HTTPResponseHead(version: req.version, status: .methodNotAllowed, headers: [
            CONNECTION: self.keepAlive ? KEEP_ALIVE : CLOSE
        ]);
        _ = context.channel.write(HTTPServerResponsePart.head(head))
    }
    
    private func handle500(_ context: ChannelHandlerContext, _ message: String) {
        let head = HTTPResponseHead(version: req.version, status: .internalServerError, headers: [
            CONNECTION: CLOSE,
            CONTENT_TYPE: MIME_JSON
        ]);
        let resp = wiltonToJson(RespObj(500, "Server Error", message))
        var body = context.channel.allocator.buffer(capacity: resp.utf8.count)
        body.writeString(resp)
        _ = context.channel.write(HTTPServerResponsePart.head(head))
        _ = context.channel.write(HTTPServerResponsePart.body(.byteBuffer(body)))
    }
    
    private func chooseDroot(_ uri: String) -> DocumentRoot? {
        for dr in droots {
            if uri.hasPrefix(dr.resource){
                return dr
            }
        }
        return nil
    }

    private func finalize(_ context: ChannelHandlerContext) {
        let endpart = HTTPServerResponsePart.end(nil)
        _ = context.channel.writeAndFlush(endpart).whenComplete { _ in
            if !self.keepAlive {
                _ = context.close(promise: nil)
            }
            // `AllowRemoteHalfClosureOption` allows users to configure whether the `Channel` will close itself when its remote
            // peer shuts down its send stream, or whether it will remain open. If set to `false` (the default), the `Channel`
            // will be closed automatically if the remote peer shuts down its send stream.
        }
    }
}
    
fileprivate class RespObj : Codable {
    let code: Int
    let message: String
    let details: String
    
    init (_ code: Int, _ message: String, _ details: String) {
        self.code = code
        self.message = message
        self.details = details
    }
}
    /*
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
    
    private func handle405(_ chan: Channel, _ req: HTTPRequestHead) {
        
    }
}

fileprivate func createHeadPart(_ req: HTTPRequestHead, _ file: URL, _ cache: Bool = true) -> HTTPServerResponsePart {
    var head = HTTPResponseHead(version: req.version, status: .ok)
    // allow webview to cache all resources for 24 hours
    if (cache) {
        head.headers.add(name: "Cache-Control", value: "public, max-age=86400")
    }
    
    // set content type
    var ct = ""
    if file.path.hasSuffix(".js") {
        ct = "application/javascript"
    } else if file.path.hasSuffix(".css") {
        ct = "text/css"
    } else if file.path.hasSuffix(".html") {
        ct = "text/html"
    } else if file.path.hasSuffix(".json") {
        ct = "application/json"
    } else if file.path.hasSuffix(".svg") {
        ct = "image/svg+xml"
    }
    if !ct.isEmpty {
        head.headers.add(name: "Content-Type", value: ct)
    }
    return HTTPServerResponsePart.head(head)
}

fileprivate func createRespBodyPart(_ req: HTTPRequestHead, _ alloc: ByteBufferAllocator, _ bytes: [UInt8]) -> HTTPServerResponsePart {
    var buffer = alloc.buffer(capacity: bytes.count)
    buffer.writeBytes(bytes);
    return HTTPServerResponsePart.body(.byteBuffer(buffer))
}


   private String postBody(IHTTPSession session) {
        HashMap<String, String> map = new HashMap<>();
        try {
            session.parseBody(map);
            String res = map.get(POST_DATA);
            return null != res ? res : "";
        } catch (Exception e) {
            e.printStackTrace();
            return "";
        }
    }

    private DocumentRoot chooseDroot(String uri) {
        for (DocumentRoot dr : droots) {
            String prefix = dr.getResource() + "/";
            if (uri.startsWith(prefix)) {
                return dr;
            }
        }
        return null;
    }

    private Response serveFile(DocumentRoot droot, String uri) throws FileNotFoundException {
        if (null == droot) {
            return Response.newFixedLengthResponse(Status.NOT_FOUND,
                    MIME_TEXT, "Not found, path: [" + uri + "]\n");
        }
        String prefix = droot.getResource() + "/";
        String uriNoPrefix = uri.substring(prefix.length());
//        if (uriNoPrefix.contains("../")) {
//            return Response.newFixedLengthResponse(Status.BAD_REQUEST,
//                    MIME_TEXT, "Bad Request, path: [" + uri + "]\n");
//        }
        String uriNoParams = uriNoPrefix;
        int qmarkIdx = uri.indexOf('?');
        if (-1 != qmarkIdx) {
            uriNoParams = uriNoPrefix.substring(0, qmarkIdx);
        }
        String path = droot.getDirPath() + "/" + uriNoParams;
        File file = new File(path);
        if (!(file.exists() && file.isFile())) {
            return Response.newFixedLengthResponse(Status.NOT_FOUND,
                    MIME_TEXT, "Not found, path: [" + uri + "]\n");
        }
        FileInputStream fis = new FileInputStream(file);
        String mime = mimeType(droot, path);
        return Response.newFixedLengthResponse(Status.OK, mime, fis, file.length());
    }
 */

fileprivate func mimeType(_ droot: DocumentRoot, _ path: String) -> String {
    for en in defaultMimes {
        if (path.hasSuffix(en.key)) {
            return en.value
        }
    }
    if let mimes = droot.mimeTypes {
        for en in mimes {
            if (path.hasSuffix(en.key)) {
                return en.value
            }
        }
    }
    return MIME_OCTET_STREAM;
}
