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
    "lodash/defaults",
    "lodash/endsWith",
    "lodash/filter",
    "lodash/forEach",
    "lodash/keys",
    "lodash/keyBy",
    "lodash/map",
    "lodash/startsWith",
    // wilton
    "wilton/fs",
    "wilton/misc",
    "wilton/zip",
    // local
    "../support/rmIfExist"
], function(
        module, Logger, // logging
        defaults, endsWith, filter, forEach, keys, keyBy, map, startsWith, // lodash
        fs, misc, zip, // wilton
        rmIfExist // local
) {
    "use strict";
    var logger = new Logger(module.id);

    function walkAndCollectPaths(dir, paths) {
        var children = fs.readdir(dir);
        forEach(children, function(ch) {
            var pa = dir + "/" + ch;
            if (fs.isFile(pa)) {
                paths.push(pa);
            } else {
                paths.push(pa + "/");
                walkAndCollectPaths(pa, paths);
            }
        });
    }

    function sortEntries(entries) {
        var list = keys(entries);
        list.sort(function(en1, en2) {
            if (endsWith(en1, "/") && !endsWith(en2, "/")) {
                return 1;
            } else if (!endsWith(en1, "/") && endsWith(en2, "/")) {
                return 0;
            } else {
                return en1.localeCompare(en2);
            }
        });
        var res = {};
        forEach(list, function(en) {
            res[en] = entries[en];
        });
        return res;
    }

    function collectAppEntries(appdir) {
        var paths = [];
        forEach([
            appdir + "conf",
            appdir + "server",
            appdir + "web"
        ], function(dir) {
            paths.push(dir + "/");
            walkAndCollectPaths(dir, paths, true);
        });

        var entries = keyBy(paths, function(pa) {
            return "app/" + pa.substring(appdir.length);
        });

        // app launcher
        entries["app/index.js"] = appdir + "index.js";

        // android entry point
        entries["init.js"] = appdir + "android/init.js";

        return entries;
    }

    function unpackStdlib(conf) {
        var baseUrl = misc.wiltonConfig().requireJs.baseUrl;
        if (startsWith(baseUrl, "file:")) {
            return baseUrl.replace(/^file:\/\//, "");
        } 
        var dest = conf.appdir + "work/stdlib/";
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

    function collectStdlibEntries(conf, stddir) {
        var paths = [];
        var dirs = map(conf.packages, function(pa) {
            return stddir + pa;
        });
        forEach(dirs, function(dir) {
            paths.push(dir + "/");
            walkAndCollectPaths(dir, paths, true);
        });

        return keyBy(paths, function(pa) {
            return "stdlib/" + pa.substring(stddir.length);
        });
    }

    return function(conf) {
        logger.info("Preparing APK resources ...");
        var destRel = "android/app/src/main/assets/" + conf.android.package + ".zip";
        var dest = conf.appdir + destRel;
        rmIfExist(dest);
        var appEntries = collectAppEntries(conf.appdir);
        var stddir = unpackStdlib(conf);
        var stdEntries = collectStdlibEntries(conf, stddir);
        var entries = defaults({}, appEntries, stdEntries);
        var sorted = sortEntries(entries);

        // write zip
        zip.writeFile(dest, sorted, {
            fsPaths: true
        });
        logger.info("Resources bundled, path: [" + destRel + "]");
    };
});
