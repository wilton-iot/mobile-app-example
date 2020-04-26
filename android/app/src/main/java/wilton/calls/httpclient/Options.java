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

import java.util.LinkedHashMap;

class Options {
    private String url;
    private String data;
    private String filePath;
    private Meta metadata;

    public Options() {
    }

    public String getUrl() {
        return url;
    }

    public String getData() {
        return data;
    }

    public String getFilePath() {
        return filePath;
    }

    public Meta getMeta() {
        return metadata;
    }

    static class Meta {
        private LinkedHashMap<String, String> headers;
        private String method;
        private boolean abortOnResponseError;
        private int connecttimeoutMillis;
        private int timeoutMillis;
        private String responseDataFilePath;

        Meta() {
        }

        Meta(LinkedHashMap<String, String> headers, String method, boolean abortOnResponseError,
             int connecttimeoutMillis, int timeoutMillis, String responseDataFilePath) {
            this.headers = headers;
            this.method = method;
            this.abortOnResponseError = abortOnResponseError;
            this.connecttimeoutMillis = connecttimeoutMillis;
            this.timeoutMillis = timeoutMillis;
            this.responseDataFilePath = responseDataFilePath;
        }

        LinkedHashMap<String, String> getHeaders() {
            return null != headers ? headers : new LinkedHashMap<String, String>();
        }

        String getMethod() {
            return method;
        }

        boolean isAbortOnResponseError() {
            return abortOnResponseError;
        }

        int getConnecttimeoutMillis() {
            return connecttimeoutMillis > 0 ? connecttimeoutMillis : 10000;
        }

        int getTimeoutMillis() {
            return timeoutMillis > 0 ? timeoutMillis : 15000;
        }

        String getResponseDataFilePath() {
            return responseDataFilePath;
        }
    }
}
