/*
 * Copyright 2020, alex at staticlibs.net
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package wilton.calls.server.impl;

import org.nanohttpd.protocols.http.IHTTPSession;
import org.nanohttpd.protocols.http.request.Method;
import org.nanohttpd.protocols.http.response.Response;
import org.nanohttpd.protocols.http.response.Status;
import org.nanohttpd.util.IHandler;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;

import wilton.rhino.RhinoScript;

import static org.nanohttpd.protocols.http.HTTPSession.POST_DATA;
import static wilton.rhino.RhinoExecutor.runOnJsThreadSync;

class HTTPHandler implements IHandler<IHTTPSession, Response> {

    private static final String MIME_TEXT = "text/plain";
    private static final String MIME_JSON = "application/json";
    private static final String MIME_OCTET_STREAM = "application/octet-stream";
    private static final LinkedHashMap<String, String> defaultMimes;

    static {
        defaultMimes = new LinkedHashMap<>();
        defaultMimes.put("txt", "text/plain");
        defaultMimes.put("js", "text/javascript");
        defaultMimes.put("json", "application/json");
        defaultMimes.put("css", "text/css");
        defaultMimes.put("html", "text/html");
        defaultMimes.put("png", "image/png");
        defaultMimes.put("jpg", "image/jpeg");
        defaultMimes.put("svg", "image/svg+xml");
    }

    private final ArrayList<DocumentRoot> droots;
    private final RhinoScript httpPostHandler;

    HTTPHandler(ArrayList<DocumentRoot> droots, RhinoScript httpPostHandler) {
        this.droots = droots;
        this.httpPostHandler = httpPostHandler;
    }

    @Override
    public Response handle(IHTTPSession session) {
        if (Method.GET.equals(session.getMethod())) {
            try {
                String uri = session.getUri().replaceAll("\\\\", "/");
                DocumentRoot droot = chooseDroot(uri);
                Response resp = serveFile(droot, uri);
                resp.setUseGzip(false);
                return resp;
            } catch (IOException e) {
                Response resp = Response.newFixedLengthResponse(Status.INTERNAL_ERROR,
                        MIME_TEXT, e.getMessage());
                resp.setUseGzip(false);
                return resp;
            }
        } else if (Method.POST.equals(session.getMethod())) {
            String resDataNullable = null;
            if (null != httpPostHandler) {
                RhinoScript ph = httpPostHandler;
                String msg = postBody(session);
                RhinoScript cb = new RhinoScript(ph.getModule(), ph.getFunc(), msg);
                if ("wilton-mobile/test/http/_postHandler".equals(ph.getModule())) {
                    // special case for testing - cannot call to JS here
                    resDataNullable = msg;
                } else {
                    resDataNullable = runOnJsThreadSync(cb);
                }
            }
            String resData = null != resDataNullable ? resDataNullable : "{}";
            Response resp = Response.newFixedLengthResponse(Status.OK, MIME_JSON, resData);
            resp.setUseGzip(false);
            return resp;
        } else {
            Response resp = Response.newFixedLengthResponse(Status.METHOD_NOT_ALLOWED,
                    MIME_TEXT, Status.METHOD_NOT_ALLOWED.getDescription() + "\n");
            resp.setUseGzip(false);
            return resp;
        }
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

    private String mimeType(DocumentRoot droot, String path) {
        for (Map.Entry<String, String> en : defaultMimes.entrySet()) {
            if (path.endsWith(en.getKey())) {
                return en.getValue();
            }
        }
        if (null != droot.getMimeTypes()) {
            for (Map.Entry<String, String> en : droot.getMimeTypes().entrySet()) {
                if (path.endsWith(en.getKey())) {
                    return en.getValue();
                }
            }
        }
        return MIME_OCTET_STREAM;
    }
}
