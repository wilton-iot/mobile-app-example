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

// top level define required because enforceDefine is used

define([], function () {

    // requirejs config, adjust as needed
    requirejs.config({
        baseUrl: "/stdlib/",
        enforceDefine: true,
        nodeIdCompat: true,
        waitSeconds: 15,
        paths: {
            "example": "/web/js/example"
        },
        // these plugins are used to load wilton-packages.json
        packages: [
            { name: "text", main: "text" },
            { name: "json", main: "json" }
        ]
    });

    // load packages config and compat globals
    require(["json!wilton-requirejs/wilton-packages.json",
        "wilton-requirejs/compatGlobals"], function (packages) {

            // complete config
            requirejs.config({
                packages: packages
            });

            // init buffer
            require(["buffer"], function (buffer) {
                // set global compat Buffer
                Buffer = buffer.Buffer;

                // start app
                require([
                    "vue",
                    "example/router",
                    "example/store",
                    "example/app"
                ], function (Vue, router, store, app) {
                    new Vue({
                        el: '#root',
                        router: router,
                        store: store,
                        template: "<App/>"
                    });
                });
            });
        });
});
