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
    // logging
    "module",
    "wilton-mobile/Logger",
    // lodash
    "lodash/filter",
    "lodash/forEach",
    "lodash/startsWith",
    // wilton
    "wilton/fs",
    "wilton/misc",
    "wilton/zip",
    // local
    "../support/rmIfExist"
], function(
        module, Logger, // logging
        filter, forEach, startsWith, // lodash
        fs, misc, zip, // wilton
        rmIfExist // local
) {
    "use strict";
    var logger = new Logger(module.id);

    function unpackStdlib(conf) {
        var baseUrl = misc.wiltonConfig().requireJs.baseUrl;
        if (startsWith(baseUrl, "file:")) {
            return baseUrl.replace(/^file:\/\//, "");
        }
        var dest = conf.appdir + "../stdlib/";
        var exists = false;
        forEach(conf.packages, function(pa) {
            exists = fs.exists(dest + pa);
            return exists;
        });
        if (!exists) {
            rmIfExist(dest);
            var wlib = baseUrl.replace(/^zip:\/\//, "");
            var list = zip.listFileEntries(wlib);
            var filtered = filter(list, function(en) {
                for (var i = 0; i < conf.packages.length; i++) {
                    var pa = conf.packages[i];
                    if (startsWith(en, pa)) {
                        return true;
                    }
                }
                return false;
            });
            var entries = {};
            forEach(filtered, function(en) {
                entries[en] = dest + en;
            });
            fs.mkdir(dest);
            zip.unzipFileEntries(wlib, entries);
            // wilton/web
            var wdir = dest + "wilton/";
            var wlist = fs.readdir(wdir);
            forEach(wlist, function(en) {
                if ("web" !== en) {
                    rmIfExist(wdir + en);
                }
            });
        }
        return dest;
    }
       
    function copyApp(conf) {
        var dest = conf.appdir + "../app/";
        rmIfExist(dest);
        fs.mkdir(dest);
        fs.copyDirectory("conf", dest + "conf");
        fs.copyDirectory("server", dest + "server");
        fs.copyDirectory("web", dest + "web");
        fs.copyFile("index.js", dest + "index.js");
    }

    return function(conf) {
        logger.info("Preparing Bundle resources ...");
        unpackStdlib(conf);
        copyApp(conf);
        rmIfExist(conf.appdir + "../init.js");
        fs.copyFile("ios/init.js", conf.appdir + "../init.js");
        logger.info("Resources bundled successfully");
    };
});
