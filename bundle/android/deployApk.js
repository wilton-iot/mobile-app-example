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
    // wilton
    "wilton/misc",
    "wilton/process",
    // local
    "../support/checkEnvVars",
    "../support/rmIfExist",
    "./createApk",
    "./logcat"
], function(
        module, Logger, // logging
        misc, process, // wilton
        checkEnvVars, rmIfExist, createApk, logcat // local
) {
    "use strict";
    var logger = new Logger(module.id);

    var env = misc.wiltonConfig().environmentVariables;

    return function(conf) {

        createApk(conf);

        logger.info("Deploying APK on device");

        checkEnvVars([
            "ANDROID_SDK_ROOT"
        ]);

        logger.info("Uninstalling application ...");
        var uninstRes = process.spawnShell([
            env["ANDROID_SDK_ROOT"] + "/platform-tools/adb", 
            "uninstall",
            conf.android.package
        ]);
        logger.info("Uninstall finished, code: [" + uninstRes + "]");

        var inOutFileRel = "work/install_out.txt";
        logger.info("Installing application ...");
        var inOutFile = conf.appdir + inOutFileRel;
        rmIfExist(inOutFileRel);
        var instRes = process.spawnShell([
            env["ANDROID_SDK_ROOT"] + "/platform-tools/adb", 
            "install",
            conf.appdir + "work/" + conf.appname + ".apk",
            "> " + inOutFile + " 2>&1"
        ]);
        if (0 !== instRes) {
            logger.error("Installation failed, code: [" + instRes + "]," +
                    " log file: [" + inOutFileRel + "]");
            return;
        }
        logger.info("Application installed successfully successfully");

        var stOutFileRel = "work/start_out.txt";
        logger.info("Starting application ...");
        var stOutFile = conf.appdir + stOutFileRel;
        rmIfExist(stOutFileRel);
        var startRes = process.spawnShell([
            env["ANDROID_SDK_ROOT"] + "/platform-tools/adb", 
            "shell",
            "am",
            "start",
            "-a",
            "android.intent.action.MAIN",
            "-n",
            conf.android.package + "/.MainActivity",
            "> " + stOutFile + " 2>&1"
        ]);
        if (0 !== startRes) {
            logger.error("Startup failed, code: [" + startRes + "]," +
                    " log file: [" + stOutFileRel + "]");
            return;
        }
        logger.info("Application started");

        logcat(conf);
    };
});
