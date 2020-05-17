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

package mobile.example.startup;

import android.app.AlertDialog;
import android.util.Log;

import wilton.rhino.RhinoScript;

import static mobile.example.AppCalls.appCalls;
import static mobile.example.MainActivity.activity;
import static wilton.Bridge.wiltonBridge;
import static wilton.rhino.RhinoRunner.rhinoRunner;
import static mobile.example.startup.Assets.unpackAssets;

public class Launch {

    public static void launchApplication() {
        try {
            unpackAssets();
            wiltonBridge().addAppCalls(appCalls());
//            RhinoScript testScript = new RhinoScript("wilton-mobile/test", null);
//            rhinoRunner().run(testScript);
            RhinoScript script = new RhinoScript("example/index", "main",
                    "--android-launch");
            rhinoRunner().run(script);
        } catch (Exception e) {
            try {
                final String msg = Log.getStackTraceString(e);
                // write to system log
                Log.e(activity().getClass().getPackage().getName(), msg);
                // show on screen
                activity().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        new AlertDialog.Builder(activity())
                                .setMessage(msg)
                                .show();
                    }
                });
            } catch (Exception e1) {
                // give up
            }
        }
    }
}
