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

function print(msg) {
    var System = Packages.java.lang.System;
    var isAndroid = -1 !== String(System.getProperty("java.specification.vendor"))
            .toLowerCase().indexOf("android");
    if (isAndroid) {
        var Log = Packages.android.util.Log;
        Log.i("mobile.example", String(msg));
    } else {
        System.out.println(String(msg));
    }
}

WILTONMOBILE_isAndroid = true;

function WILTON_wiltoncall(name, params) {
    var jstr = WILTONMOBILE_androidBridge.wiltoncall(String(name), String(params));
    if (null !== jstr) {
        return String(jstr);
    }
    return jstr;
}

(function(){

    // Rhino Object.keys fix
    // "new String(...)" is not iterable with "for key in .." in Rhino
    Object_keys_orig = Object.keys;
    Object.keys = function(obj) {
        if ("object" === typeof (obj) && obj instanceof String) {
            var res = Object_keys_orig(obj);
            if (res.length !== obj.length) {
                res = [];
                for (var i = 0; i < obj.length; i++) {
                    res.push(String(i));
                }
            }
            return res;
        }
        return Object_keys_orig(obj);
    };

    // init
    var filesDir = WILTON_wiltoncall("fs_files_dir");
    WILTON_load(filesDir + "stdlib/wilton-requirejs/wilton-require.js");
}());
