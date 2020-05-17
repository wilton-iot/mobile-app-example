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
    var Vuex = require("vuex");
    var storeHolder = require("vue-require/store/storeHolder");

    Vue.use(Vuex);

    var res = new Vuex.Store({
        strict: true,

        actions: {
            hideSplash: require("./common/actions/hideSplash"),
            openBackendSocket: require("./common/actions/openBackendSocket"),
            sayHello: require("./common/actions/sayHello"),
            showMessage: require("./common/actions/showMessage"),
            subscribeBackButton: require("./common/actions/subscribeBackButton")
        },

        modules: {
            broadcast: require("./modules/broadcast/broadcastStore")
        },

        mutations: {
            updateCanGoBack: require("./common/mutations/updateCanGoBack"),
            updateCanGoForward: require("./common/mutations/updateCanGoForward"),
            updateCanGoToMenu: require("./common/mutations/updateCanGoToMenu")
        },

        state: {
            transient: {
                canGoForward: false,
                canGoBack: false,
                canGoToMenu: true
            }
        }
    });
    
    storeHolder.set(res);

    return res;

});
