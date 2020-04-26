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

public class RhinoScript {
    private String module;
    private String func;
    private Object[] args;

    public RhinoScript() {
    }

    public RhinoScript(String module) {
        this.module = module;
    }

    public RhinoScript(String module, String func) {
        this.module = module;
        this.func = func;
    }

    public RhinoScript(String module, String func, Object... args) {
        this.module = module;
        this.func = func;
        this.args = args;
    }

    public String getModule() {
        return module;
    }

    public String getFunc() {
        return func;
    }

    public Object[] getArgs() {
        return args;
    }
}
