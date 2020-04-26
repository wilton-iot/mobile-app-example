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
    "module",
    "vue-require/router/pushBack",
    "vue-require/store/dispatch",
    "example/components/header/Header",
    "text!./exit.html"
], function (module, pushBack, dispatch, Header, template) {
    "use strict";

    return {
        template: template,

        components: {
            "example-header": new Header("Exit", "Do you want to exit the application?")
        },

        data: function() {
            return {
                module: module,

                listItem: {
                    label: "Exit",
                    description: "Exit the application",
                    path: "/exit"
                }
            };
        },

        methods: {
            pushBack: pushBack,
            dispatch: dispatch
        }
    };
});
