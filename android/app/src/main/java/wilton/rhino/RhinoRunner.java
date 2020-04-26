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

import org.mozilla.javascript.Context;
import org.mozilla.javascript.ContextFactory;
import org.mozilla.javascript.Function;
import org.mozilla.javascript.FunctionObject;
import org.mozilla.javascript.Script;
import org.mozilla.javascript.ScriptableObject;
import org.mozilla.javascript.Undefined;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;

import mobile.example.Bridge;
import mobile.example.MainActivity;
import wilton.WiltonException;

import static org.apache.commons.io.IOUtils.closeQuietly;
import static wilton.rhino.RhinoLoader.rhinoLoadMethod;
import static mobile.example.utils.JsonUtils.GSON;

public class RhinoRunner {

    // can only be used from rhino thread
    private static RhinoRunner INSTANCE = null;

    private final Context context;
    private final ScriptableObject scope;
    private final long threadId;

    private RhinoRunner() {
        try {
            // init engine
            ContextFactory.initGlobal(new RhinoContextFactory());
            this.context = Context.enter();
            this.scope = context.initStandardObjects();
            this.threadId = Thread.currentThread().getId();

            // bridge
            Object wrappedOut = Context.javaToJS(new Bridge(), scope);
            ScriptableObject.putProperty(scope, "WILTONMOBILE_androidBridge", wrappedOut);

            // rhino load func
            FunctionObject loadFunc = new FunctionObject("WILTON_load", rhinoLoadMethod(), scope);
            scope.put("WILTON_load", scope, loadFunc);
            scope.setAttributes("WILTON_load", ScriptableObject.DONTENUM);

        } catch (IOException e) {
            throw new WiltonException("Rhino initialization error", e);
        }
    }

    public static RhinoRunner rhinoRunner() {
        if (INSTANCE == null) {
            INSTANCE = new RhinoRunner();
            runInitScript(INSTANCE.context, INSTANCE.scope);
        }
        return INSTANCE;
    }

    public String run(RhinoScript script) {
        long tid = Thread.currentThread().getId();
        if (tid != threadId) {
            throw new WiltonException("Attempt to run JS from invalid thread," +
                    " id: [" + tid + "], expected: [" + threadId + "]");
        }
        Function wiltonRun = (Function) scope.get("WILTON_run", scope);
        String argsJson = GSON.toJson(script);
        Object resObj = wiltonRun.call(context, scope, scope, new Object[] {argsJson});
        if (null != resObj && Undefined.instance != resObj) {
            return String.valueOf(resObj);
        }
        return null;
    }

    void runScript(Script script) {
        script.exec(context, scope);
    }

    private static void runInitScript(Context context, ScriptableObject scope) {
        // find startup script
        File filesDir = MainActivity.activity().getExternalFilesDir(null);
        File initScript = new File(filesDir, "init.js");

        // run startup script
        InputStream is = null;
        try {
            is = new FileInputStream(initScript);
            Reader reader = new InputStreamReader(is, "UTF-8");
            context.evaluateReader(scope, reader, initScript.getAbsolutePath(), 1, null);
        } catch (IOException e) {
            throw new RuntimeException(e);
        } finally {
            closeQuietly(is);
        }
    }

}
