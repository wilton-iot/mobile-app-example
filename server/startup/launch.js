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
    // libs
    "module",
    "argparse",
    "wilton-mobile/Logger",
    // common
    "../common/appdir",
    "../common/loadConfig",
    // local
    "./createDirs",
    "./launchAndroid"
], function(
        module, argparse, Logger, // lib
        appdir, loadConfig, // common
        createDirs, launchAndroid // local
) {
    "use strict";
    var logger = new Logger(module.id);

    function createArgParser() {
        // parser
        var ap = new argparse.ArgumentParser({
            addHelp: false,
            nargs: argparse.Const.REMAINDER,
            prog: "example",
            description: "example application",
            usage: "wilton index.js -- [options]"
        });

        // https://github.com/wilton-iot/argparse#addargument-method

        // android
        ap.addArgument(["--android-launch"], {
            action: "storeTrue",
            dest: "androidLaunch",
            defaultValue: false,
            help: "Launch Android application"
        });
        ap.addArgument(["--android-logcat"], {
            action: "storeTrue",
            dest: "androidLogcat",
            defaultValue: false,
            help: "Connect to Android device and listen to logcat log"
        });
        ap.addArgument(["--android-apk-prepare"], {
            action: "storeTrue",
            dest: "androidApkPrepare",
            defaultValue: false,
            help: "Prepare resources for Android APK"
        });
        ap.addArgument(["--android-apk-create"], {
            action: "storeTrue",
            dest: "androidApkCreate",
            defaultValue: false,
            help: "Create Android APK"
        });
        ap.addArgument(["--android-apk-deploy"], {
            action: "storeTrue",
            dest: "androidApkDeploy",
            defaultValue: false,
            help: "Build Android APK and deploy to connected device"
        });
       
        // ios
        ap.addArgument(["--ios-bundle-prepare"], {
            action: "storeTrue",
            dest: "iosBundlePrepare",
            defaultValue: false,
            help: "Prepare resources for iOS bundle"
        });

        // other
        ap.addArgument(["--check-sanity"], {
            action: "storeTrue",
            dest: "checkSanity",
            defaultValue: false,
            help: "Perform sanity check for this application"
        });
        ap.addArgument(["-h", "--help"], {
            action: "storeTrue",
            dest: "help",
            defaultValue: false,
            help: "Prints this message"
        });

        return ap;
    }

    return function() {
        // create arg parser
        var ap = createArgParser();

        // parse arguments
        var args = null;
        try {
            var arglist = Array.prototype.slice.call(arguments);
            args = ap.parseArgs(arglist);
        } catch (e) {
            // print details and exit on invalid args
            print(e.message);
            ap.printUsage();
            return 2;
        }

        // load configuration file 
        var conf = loadConfig();
        // prepare neccessary directories
        createDirs(conf);

        // run aplication
        if (args.help) {
            ap.printHelp();
            return;
        } else if (args.checkSanity) {
            return 0;
        } else if (args.androidLaunch) {
            return launchAndroid(conf);
        } else if (args.androidLogcat) {
            return require(["example/bundle/android/logcat"], function(fun) { fun(conf); });
        } else if (args.androidApkPrepare) {
            return require(["example/bundle/android/prepareApk"], function(fun) { fun(conf); });
        } else if (args.androidApkCreate) {
            return require(["example/bundle/android/createApk"], function(fun) { fun(conf); });
        } else if (args.androidApkDeploy) {
            return require(["example/bundle/android/deployApk"], function(fun) { fun(conf); });
        } else if (args.iosBundlePrepare) {
            return require(["example/bundle/ios/prepareBundle"], function(fun) { fun(conf); })
        } else {
            return require(["example/server/startup/launchDev"], function(fun) { fun(conf); });
        }
    };

});

