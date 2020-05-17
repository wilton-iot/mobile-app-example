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

package wilton.calls.ui;

import android.webkit.WebView;
import android.webkit.WebViewClient;

import java.util.concurrent.CountDownLatch;

import mobile.example.R;
import wilton.Call;

import static mobile.example.MainActivity.activity;
import static wilton.support.WiltonJson.wiltonFromJson;

public class WebViewLoad implements Call {

    @Override
    public String call(String data) throws Exception {
        final Options opts = wiltonFromJson(data, Options.class);
        final CountDownLatch latch = new CountDownLatch(1);
        activity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                try {
                    // init webview
                    WebView webView = activity().findViewById(R.id.activity_main_webview);
                    // Force links and redirects to open in the WebView instead of in a browser
                    webView.setWebViewClient(new WebViewClient());
                    webView.getSettings().setJavaScriptEnabled(true);
                    webView.loadUrl(opts.url);
                } finally {
                    latch.countDown();
                }
            }
        });
        latch.await();
        return null;
    }

    static class Options {
        String url;
    }
}
