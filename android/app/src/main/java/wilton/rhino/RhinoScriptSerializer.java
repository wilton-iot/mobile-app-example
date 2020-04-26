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

import com.google.gson.JsonElement;
import com.google.gson.JsonSerializationContext;
import com.google.gson.JsonSerializer;

import java.lang.reflect.Type;
import java.util.LinkedHashMap;

import static mobile.example.utils.JsonUtils.GSON;

public class RhinoScriptSerializer implements JsonSerializer<RhinoScript> {
    @Override
    public JsonElement serialize(RhinoScript src, Type typeOfSrc, JsonSerializationContext context) {
        LinkedHashMap<String, Object> params = new LinkedHashMap<>();
        params.put("module", src.getModule());
        if (null != src.getFunc()) {
            params.put("func", src.getFunc());
        }
        if (null != src.getArgs()) {
            params.put("args", src.getArgs());
        }
        return GSON.toJsonTree(params);
    }
}
