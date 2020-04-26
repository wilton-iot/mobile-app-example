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
    // id
    "module",
    // common
    "vue-require/store/commit",
    // components
    "example/components/header/Header",
    "example/components/list/List",
    // modules
    "example/modules/broadcast/broadcast",
    "example/modules/exit/exit",
    "example/modules/hello/hello",
    // other
    "text!./menu.html"
], function (
        module, // id
        commit, // common
        Header, List, // components
        broadcast, exit, hello, // modules
        template // other
) {
    "use strict";

    function modsListItems(mods) {
        var res = [];
        for (var i = 0; i < mods.length; i++) {
            res.push(mods[i].data().listItem);
        }
        return res;
    }

    return {
        template: template,

        components: {
            "example-header": new Header("Menu", "Choose a section of MyApp application from a list below"),
            "example-list": new List(modsListItems([
                hello,
                broadcast,
                exit
            ]))
        },

        created: function() {
            commit("updateCanGoToMenu", false);
        },

        destroyed: function() {
            commit("updateCanGoToMenu", true);
        },

        data: function() {
            return {
                module: module
            };
        }
    };
});
