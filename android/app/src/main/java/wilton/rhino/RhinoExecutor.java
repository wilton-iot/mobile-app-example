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

package wilton.rhino;

import android.util.Log;

import java.util.concurrent.CountDownLatch;
import java.util.concurrent.Executor;

import static java.util.concurrent.Executors.newSingleThreadExecutor;
import static mobile.example.MainActivity.activity;
import static wilton.rhino.RhinoRunner.rhinoRunner;

public class RhinoExecutor {
    private static final Executor INSTANCE = newSingleThreadExecutor(new RhinoThreadFactory());

    public static void runOnJsThread(Runnable runnable) {
        INSTANCE.execute(runnable);
    }

    public static void runOnJsThread(final RhinoScript script) {
        INSTANCE.execute(new Runnable() {
            @Override
            public void run() {
                try {
                    rhinoRunner().run(script);
                } catch (Exception e) {
                    String msg = Log.getStackTraceString(e);
                    Log.e(activity().getClass().getPackage().getName(), msg);
                }
            }
        });
    }

    public static String runOnJsThreadSync(final RhinoScript script) {
        final String[] holder = new String[1];
        holder[0] = null;
        final CountDownLatch latch = new CountDownLatch(1);
        INSTANCE.execute(new Runnable() {
            @Override
            public void run() {
                try {
                    String res = rhinoRunner().run(script);
                    holder[0] = res;
                } catch (Exception e) {
                    String msg = Log.getStackTraceString(e);
                    Log.e(activity().getClass().getPackage().getName(), msg);
                } finally {
                    latch.countDown();
                }
            }
        });
        // await script execution
        try {
            latch.await();
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new RuntimeException(e);
        }
        return holder[0];
    }
}
