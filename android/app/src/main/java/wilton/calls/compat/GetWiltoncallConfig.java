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

package wilton.calls.compat;

import com.google.gson.reflect.TypeToken;

import java.io.File;
import java.io.IOException;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.LinkedHashMap;

import wilton.Call;
import wilton.support.WiltonException;

import static org.apache.commons.io.FileUtils.readFileToString;
import static mobile.example.MainActivity.activity;
import static wilton.support.WiltonJson.wiltonFromJson;
import static wilton.support.WiltonJson.wiltonToJson;

public class GetWiltoncallConfig implements Call {

    private final Config config;

    public GetWiltoncallConfig() throws WiltonException {
        try {
            File filesDir = activity().getExternalFilesDir(null);
            String baseUrl = new File(filesDir, "stdlib").getAbsolutePath();
            LinkedHashMap<String, String> paths = new LinkedHashMap<>();
            File packagesFile = new File(filesDir, "stdlib/wilton-requirejs/wilton-packages.json");
            String text = readFileToString(packagesFile, "UTF-8");
            paths.put("example", new File(filesDir, "app").getAbsolutePath());
            ArrayList<Config.RequireJS.Package> packages = wiltonFromJson(text, Config.RequireJS.PACKAGES_JSON_TYPE);
            this.config = new Config(baseUrl, paths, packages);
        } catch (IOException e) {
            throw new WiltonException("Error retrieving Wilton config", e);
        }
    }

    public String call(final String data) throws Exception {
        return wiltonToJson(this.config);
    }

    private static class Config {
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

        Config(String baseUrl, LinkedHashMap<String, String> paths, ArrayList<RequireJS.Package> packages) {
            this.requireJs = new RequireJS(baseUrl, paths, packages);
        }

        static class RequireJS {
            static final Type PACKAGES_JSON_TYPE = new TypeToken<ArrayList<Package>>() {}.getType();

            private int waitSeconds = 0;
            private boolean enforceDefine = true;
            private boolean nodeIdCompat = true;
            private String baseUrl;
            private LinkedHashMap<String, String> paths;
            private ArrayList<Package> packages;

            RequireJS() {
            }

            RequireJS(String baseUrl, LinkedHashMap<String, String> paths, ArrayList<Package> packages) {
                this.baseUrl = baseUrl;
                this.paths = paths;
                this.packages = packages;
            }

            static class Package {
                private String name;
                private String main;

                public Package() {
                }
            }
        }
    }
}
