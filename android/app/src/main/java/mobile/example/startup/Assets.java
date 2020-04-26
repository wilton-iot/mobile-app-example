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

import android.util.Log;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

import mobile.example.BuildConfig;

import static org.apache.commons.io.IOUtils.closeQuietly;
import static org.apache.commons.io.IOUtils.copyLarge;
import static mobile.example.MainActivity.activity;
import static mobile.example.startup.Versioning.backupExistingApp;
import static mobile.example.startup.Versioning.readAppVersion;
import static mobile.example.startup.Versioning.writeAppVersion;

class Assets {
    static void unpackAssets() throws IOException {
        File filesDir = activity().getExternalFilesDir(null);
        int ver = BuildConfig.VERSION_CODE;
        File verPath = new File(filesDir, ".appversion");
        int exVer = readAppVersion(verPath);
        if (ver == exVer) {
            return;
        }
        if (0 != exVer) {
            backupExistingApp(filesDir, exVer);
        }
        Log.i(activity().getClass().getPackage().getName(), "Installing app, version: [" + ver + "]");
        unpackAssetsZip(filesDir, activity().getClass().getPackage().getName() + ".zip");
        writeAppVersion(verPath);
    }


    private static void unpackAssetsZip(File dir, String zipAsset) throws IOException {
        InputStream is = null;
        try {
            is = activity().getAssets().open(zipAsset);
            ZipInputStream zis = new ZipInputStream(is);
            ZipEntry entry;
            while (null != (entry = zis.getNextEntry())) {
                File target = new File(dir, entry.getName());
                if (entry.isDirectory()) {
                    boolean success = target.mkdirs();
                    if (!success) {
                        throw new IOException("Cannot create directory: [" + target.getAbsolutePath() + "]");
                    }
                } else {
                    unpackZipFile(zis, target);
                }
            }
        } finally {
            closeQuietly(is);
        }
    }

    private static void unpackZipFile(ZipInputStream zis, File target) throws IOException {
//        Log.i(activity().getClass().getPackage().getName(), "Installing: " + target.getAbsolutePath());
        FileOutputStream fos = null;
        try {
            fos = new FileOutputStream(target);
            copyLarge(zis, fos);
        } finally {
            closeQuietly(fos);
        }
    }
}
