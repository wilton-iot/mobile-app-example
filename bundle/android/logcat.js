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
    "../support/rmIfExist"
], function(
        module, Logger, // logging
        misc, process, // wilton
        checkEnvVars, rmIfExist // local
) {
    "use strict";
    var logger = new Logger(module.id);

    var env = misc.wiltonConfig().environmentVariables;

    return function(conf) {

        checkEnvVars([
            "ANDROID_SDK_ROOT"
        ]);

        var outFileRel = "work/logcat_out.txt";
        logger.info("Starting Logcat, log file: [" + outFileRel + "], press 'Ctrl+C' to stop ...");
        var outFile = conf.appdir + outFileRel;
        rmIfExist(outFile);
        process.spawnShell([
            env["ANDROID_SDK_ROOT"] + "/platform-tools/adb", 
            "logcat",
            "> " + outFile + " 2>&1"
        ]);
        // grep -E "(chromium|NanoHTTPD|myapp.android|^E/art)

        logger.info("Logcat stopped");
    };
});
