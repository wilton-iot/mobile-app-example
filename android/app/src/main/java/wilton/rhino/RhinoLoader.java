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
import org.mozilla.javascript.Function;
import org.mozilla.javascript.Script;
import org.mozilla.javascript.Scriptable;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.lang.reflect.Method;

import static org.apache.commons.io.IOUtils.closeQuietly;
import static wilton.rhino.RhinoRunner.rhinoRunner;

public class RhinoLoader {

    static Method rhinoLoadMethod() {
        try {
            return RhinoLoader.class.getMethod("loadScript", Context.class,
                    Scriptable.class, Object[].class, Function.class);
        } catch (NoSuchMethodException e) {
            throw new RuntimeException(e);
        }
    }

    public static void loadScript(Context cx, Scriptable thisObj, Object[] args, Function funObj) throws IOException {
        for (Object arg : args) {
            String filePath = Context.toString(arg);
            InputStream is = null;
            Script script = null;
            try {
                is = new FileInputStream(filePath);
                Reader reader = new InputStreamReader(is, "UTF-8");
                script = cx.compileReader(reader, filePath, 1, null);
            } finally {
                closeQuietly(is);
            }
            if (null != script) {
                rhinoRunner().runScript(script);
            }
        }
    }

}
