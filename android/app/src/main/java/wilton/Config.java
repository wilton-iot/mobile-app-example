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

package wilton;

import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.LinkedHashMap;

public class Config {

    private static final String MOBILE_UNSUPPORTED = "MOBILE_UNSUPPORTED";

    private String defaultScriptEngine = "rhino";
    private String wiltonExecutable = MOBILE_UNSUPPORTED;
    private String wiltonHome = MOBILE_UNSUPPORTED;
    private String wiltonVersion = MOBILE_UNSUPPORTED;
    private RequireJS requireJs;
    private LinkedHashMap<String, String> environmentVariables = new LinkedHashMap<>();
    private String compileTimeOS = "mobile";
    private int debugConnectionPort = -1;
    private boolean traceEnable = false;
    private String cryptCall = "";

    public Config() {
    }

    public Config(String baseUrl, LinkedHashMap<String, String> paths, ArrayList<RequireJS.Package> packages) {
        this.requireJs = new RequireJS(baseUrl, paths, packages);
    }

    public static class RequireJS {
        public static final Type PACKAGES_JSON_TYPE = new TypeToken<ArrayList<RequireJS.Package>>() {}.getType();

        private int waitSeconds = 0;
        private boolean enforceDefine = true;
        private boolean nodeIdCompat = true;
        private String baseUrl;
        private LinkedHashMap<String, String> paths;
        private ArrayList<Package> packages;

        public RequireJS() {
        }

        public RequireJS(String baseUrl, LinkedHashMap<String, String> paths, ArrayList<Package> packages) {
            this.baseUrl = baseUrl;
            this.paths = paths;
            this.packages = packages;
        }

        public int getWaitSeconds() {
            return waitSeconds;
        }

        public boolean isEnforceDefine() {
            return enforceDefine;
        }

        public boolean isNodeIdCompat() {
            return nodeIdCompat;
        }

        public String getBaseUrl() {
            return baseUrl;
        }

        public LinkedHashMap<String, String> getPaths() {
            return paths;
        }

        public ArrayList<Package> getPackages() {
            return packages;
        }

        public static class Package {
            private String name;
            private String main;

            public Package() {
            }

            public Package(String name, String main) {
                this.name = name;
                this.main = main;
            }

            public String getName() {
                return name;
            }

            public String getMain() {
                return main;
            }
        }
    }
}
