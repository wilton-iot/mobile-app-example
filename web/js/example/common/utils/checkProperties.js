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

define([
    "./listProperties"
], function(listProperties) {
    "use strict";

    return function(obj, props) {
        if (undefined === typeof(obj) || null === obj) {
            throw new Error("'checkProperties' error: specified object is invalid");
        }
        if (undefined === typeof(props) || null === props || !(props instanceof Array) || 0 === props.length) {
            throw new Error("'checkProperties' error: specified props are invalid");
        }
        for (var i = 0; i < props.length; i++) {
            var pr = props[i];
            if ("string" !== typeof (pr)) {
                throw new Error("'checkProperties' error:" +
                        " invalid non-string property name: [" + pr + "], object: [" + listProperties(obj) + "]");
            }
            if (!obj.hasOwnProperty(pr)) {
                throw new Error("'checkProperties' error:" +
                        " missed property name: [" + pr + "], object: [" + listProperties(obj) + "]");
            }
        }
    };
});
