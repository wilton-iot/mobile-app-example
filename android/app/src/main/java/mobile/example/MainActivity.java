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

package mobile.example;

import android.app.Activity;
import android.os.Bundle;

import wilton.rhino.RhinoScript;

import static wilton.rhino.RhinoExecutor.runOnJsThread;
import static mobile.example.startup.Launch.launchApplication;

public class MainActivity extends Activity {
    // launchMode="singleInstance"
    private static volatile MainActivity INSTANCE = null;

    public static MainActivity activity() {
        return INSTANCE;
    }

    // Activity callbacks

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        if (null == INSTANCE) {
            INSTANCE = this;
        }

        setContentView(R.layout.activity_main);

        super.onCreate(savedInstanceState);

        runOnJsThread(new Runnable() {
            @Override
            public void run() {
                launchApplication();
            }
        });
    }

    @Override
    public void onBackPressed() {
        fireEvent("onBackPressed");
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        fireEvent("onDestroy");
    }

    @Override
    public void onLowMemory() {
        super.onLowMemory();
        fireEvent("onLowMemory");
    }

    @Override
    protected void onPause() {
        super.onPause();
        fireEvent("onPause");
    }

    @Override
    protected void onRestart() {
        super.onRestart();
        fireEvent("onRestart");
    }

    @Override
    protected void onResume() {
        super.onResume();
        fireEvent("onResume");
    }

    @Override
    protected void onStart() {
        super.onStart();
        fireEvent("onStart");
    }

    @Override
    protected void onStop() {
        super.onStop();
        fireEvent("onStop");
    }

    private static void fireEvent(String event) {
        runOnJsThread(new RhinoScript(
                "wilton-mobile/events/fireEvent", null, event));
    }

}
