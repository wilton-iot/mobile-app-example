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

package mobile.example.startup;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;

import mobile.example.BuildConfig;

import static org.apache.commons.io.IOUtils.closeQuietly;
import static org.apache.commons.io.IOUtils.copyLarge;

class Versioning {

    static int readAppVersion(File path) throws IOException {
        if (path.exists()) {
            FileInputStream fis = null;
            try {
                fis = new FileInputStream(path);
                ByteArrayOutputStream baos = new ByteArrayOutputStream();
                copyLarge(fis, baos);
                String str = baos.toString("UTF-8");
                return Integer.parseInt(str);
            } finally {
                closeQuietly(fis);
            }
        } else {
            return 0;
        }
    }

    static void writeAppVersion(File path) throws IOException {
        String ver = String.valueOf(BuildConfig.VERSION_CODE);
        OutputStreamWriter writer = null;
        try {
            FileOutputStream fos = new FileOutputStream(path);
            writer = new OutputStreamWriter(fos, "UTF-8");
            writer.write(ver);
        } finally {
            closeQuietly(writer);
        }
    }

    static void backupExistingApp(File filesDir, int exVer) throws IOException {
        File appDir = new File(filesDir, "app");
        File stdDir = new File(filesDir, "stdlib");
        File initFile = new File(filesDir, "init.js");
        File versionDir = new File(filesDir, String.valueOf(exVer));
        boolean mkSuccess = versionDir.mkdir();
        if (!mkSuccess) {
            throw new IOException("Cannot create backup directory, path: [" + versionDir.getAbsolutePath() + "]");
        }
        boolean appSuccess = appDir.renameTo(new File(versionDir, appDir.getName()));
        boolean stdSuccess = stdDir.renameTo(new File(versionDir, stdDir.getName()));
        boolean initSuccess = initFile.renameTo(new File(versionDir, initFile.getName()));
        if (!appSuccess && stdSuccess && initSuccess) {
            throw new IOException("Cannot backup existing app, path: [" + versionDir.getAbsolutePath() + "]");
        }
    }
}
