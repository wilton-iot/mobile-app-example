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
    WILTONMOBILE_iosBridge.print_(String(msg));
}

WILTONMOBILE_isIOS = true;

function WILTON_wiltoncall(name, params) {
    return WILTONMOBILE_iosBridge.wiltoncall(String(name), String(params));
}

function WILTON_load(path) {
    return WILTONMOBILE_iosBridge.loadScript(path);
}

(function(){
    // init
    var filesDir = WILTON_wiltoncall("fs_files_dir");
    WILTON_load(filesDir + "stdlib/wilton-requirejs/wilton-require.js");
}());
