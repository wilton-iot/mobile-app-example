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

import android.view.View;

import java.util.concurrent.CountDownLatch;

import mobile.example.R;
import wilton.Call;

import static mobile.example.MainActivity.activity;

public class HideSplash implements Call {

    @Override
    public String call(String data) throws Exception {
        final CountDownLatch latch = new CountDownLatch(1);
        activity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                View splash = activity().findViewById(R.id.loading_splash);
                splash.setVisibility(View.GONE);
                latch.countDown();
            }
        });
        latch.await();
        return null;
    }
}
