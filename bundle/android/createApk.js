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
    "wilton/fs",
    "wilton/misc",
    "wilton/process",
    // local
    "../support/checkEnvVars",
    "../support/jvmArgs",
    "../support/rmIfExist",
    "./prepareApk"
], function(
        module, Logger, // logging
        fs, misc, process, // wilton
        checkEnvVars, jvmArgs, rmIfExist, prepareApk // local
) {
    "use strict";
    var logger = new Logger(module.id);

    var env = misc.wiltonConfig().environmentVariables;

    return function(conf) {

        prepareApk(conf);

        logger.info("Bundling APK ...");

        checkEnvVars([
            "JAVA_HOME",
            "GRADLE_HOME",
            "ANDROID_SDK_ROOT"
        ]);

        logger.info("Cleaning up old build artifacts");
        var destFileRel = "work/" + conf.appname + ".apk";
        rmIfExist(conf.appdir + "android/.gradle");
        rmIfExist(conf.appdir + destFileRel);
        rmIfExist(conf.appdir + "android/app/build");

        logger.info("Running Gradle ...");
        var outFileRel = "work/gradle_out.txt";
        var outFile = conf.appdir + outFileRel;
        rmIfExist(outFile);
        var code = process.spawnShell([
            "cd " + conf.appdir + "android &&",
            env["GRADLE_HOME"] + "/bin/gradle",
            "-Dorg.gradle.java.home=" + env["JAVA_HOME"],
            "-Dorg.gradle.jvmargs=\"" + jvmArgs + "\"", 
            "-Dorg.gradle.parallel=false",
            "-Dorg.gradle.daemon=false",
            "clean",
            "assembleDebug",
            "> " + outFile + " 2>&1"
        ]);
        if (0 !== code) {
            throw new Error("Gradle invocation failure, code: [" + code + "]" +
                    " output: [" + outFileRel + "]");
        }
        var defaultOut = conf.appdir + "android/app/build/outputs/apk/debug/app-debug.apk";
        fs.rename(defaultOut, conf.appdir + destFileRel);

        logger.info("APK created successfully, path: [" + destFileRel + "]");
    };
});
