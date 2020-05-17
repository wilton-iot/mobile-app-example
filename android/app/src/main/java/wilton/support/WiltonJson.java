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

package wilton.support;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonElement;

import java.lang.reflect.Type;

import wilton.rhino.RhinoScript;
import wilton.rhino.RhinoScriptSerializer;

public class WiltonJson {
    private static final Gson GSON = new GsonBuilder()
            .setPrettyPrinting()
            .registerTypeAdapter(RhinoScript.class, new RhinoScriptSerializer())
            .create();

    public static String wiltonToJson(Object src) {
        return GSON.toJson(src);
    }

    public static JsonElement wiltonToJsonTree(Object src) {
        return GSON.toJsonTree(src);
    }

    public static <T> T wiltonFromJson(String json, Class<T> classOfT) {
        return GSON.fromJson(json, classOfT);
    }

    public static <T> T wiltonFromJson(String json, Type typeOfT) {
        return GSON.fromJson(json, typeOfT);
    }
}
