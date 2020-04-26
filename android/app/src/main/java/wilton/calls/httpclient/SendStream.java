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

package wilton.calls.httpclient;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.ByteArrayOutputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.LinkedHashMap;
import java.util.Map;

import wilton.WiltonException;

import static org.apache.commons.io.IOUtils.closeQuietly;
import static org.apache.commons.io.IOUtils.copyLarge;
import static mobile.example.utils.JsonUtils.GSON;

class SendStream {
    static Result sendStream(Options opts, InputStream inputStream) throws Exception {
        if (null == opts.getUrl() || opts.getUrl().isEmpty()) {
            throw new WiltonException("Invalid empty URL specified");
        }
        Options.Meta metaIn = null != opts.getMeta() ? opts.getMeta() : new Options.Meta();
        Options.Meta meta = new Options.Meta(
                metaIn.getHeaders(),
                null != metaIn.getMethod() ? metaIn.getMethod() :
                        ((null != opts.getData() || null != opts.getFilePath()) ? "POST" : "GET"),
                metaIn.isAbortOnResponseError(),
                metaIn.getConnecttimeoutMillis(),
                metaIn.getTimeoutMillis(),
                metaIn.getResponseDataFilePath());
        URL url = new URL(opts.getUrl());
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        try {
            // method
            conn.setRequestMethod(meta.getMethod());
            if ("POST".equals(meta.getMethod())) {
                conn.setDoOutput(true);
            }
            // headers
            conn.setRequestProperty("Content-Type", "application/octet-stream");
            for (Map.Entry<String, String> en : meta.getHeaders().entrySet()) {
                conn.setRequestProperty(en.getKey(), en.getValue());
            }
            // connecttimeoutMillis
            conn.setConnectTimeout(meta.getConnecttimeoutMillis());
            // timeoutMillis, todo: check whether for single read
            conn.setReadTimeout(meta.getTimeoutMillis());

            // connect
            conn.connect();

            // send data
            if ("POST".equals(meta.getMethod())) {
                BufferedOutputStream out =  null;
                try {
                    out = new BufferedOutputStream(conn.getOutputStream());
                    copyLarge(inputStream, out);
                } finally {
                    closeQuietly(out);
                }
            }

            // response code
            int responseCode = conn.getResponseCode();
            if (meta.isAbortOnResponseError() && responseCode >= 400) {
                throw new WiltonException("Error response from server," +
                        " url: [" + opts.getUrl() + "]," +
                        " code: [" + responseCode + "]");
            }

            // read response, todo: threshold
            final String resData;
            InputStream input = null;
            OutputStream dest = null;
            boolean tofile = responseCode < 400 && null != meta.getResponseDataFilePath();
            try {
                InputStream stream = responseCode < 400 ? conn.getInputStream() : conn.getErrorStream();
                input = new BufferedInputStream(stream);
                if (tofile) {
                    dest = new BufferedOutputStream(new FileOutputStream(meta.getResponseDataFilePath()));
                    copyLarge(input, dest);
                    resData = GSON.toJson(new ResponseDataFilePath(meta.getResponseDataFilePath()));
                } else {
                    dest = new ByteArrayOutputStream();
                    ByteArrayOutputStream baos = (ByteArrayOutputStream) dest;
                    copyLarge(input, dest);
                    resData = new String(baos.toByteArray(), "UTF-8");
                }
            } finally {
                closeQuietly(input);
                closeQuietly(dest);
            }

            // headers
            LinkedHashMap<String, String> headers = new LinkedHashMap<>();
            for (int i = 0; i < conn.getHeaderFields().size(); i++) {
                headers.put(conn.getHeaderFieldKey(i), conn.getHeaderField(i));
            }

            return new Result(responseCode, resData, headers);
        } finally {
            conn.disconnect();
        }
    }

    private static class ResponseDataFilePath {
        private final String responseDataFilePath;

        ResponseDataFilePath(String responseDataFilePath) {
            this.responseDataFilePath = responseDataFilePath;
        }
    }
}
