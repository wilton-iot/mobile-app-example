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

define(function(require) {
    "use strict";

    var Vue = require("vue");
    var VueRouter = require("vue-router");
    var routerHolder = require("vue-require/router/routerHolder");

    Vue.use(VueRouter);

    var res = new VueRouter({
        linkActiveClass: "active",
        linkExactActiveClass: "active",
        routes: [
            { path: "/", redirect: "/hello" },
            { path: "/menu", component: require("./modules/menu/menu") },
            { path: "/hello", component: require("./modules/hello/hello") },
            { path: "/broadcast", component: require("./modules/broadcast/broadcast") }
        ]
    });

    routerHolder.set(res);

    return res;
});
