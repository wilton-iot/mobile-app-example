//
//  GetWiltoncallConfig.swift
//  ios
//
//  Created by Alexey Liverty on 6/1/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation

private let MOBILE_UNSUPPORTED: String = "MOBILE_UNSUPPORTED"

class GetWiltoncallConfig : Call {
    private let config: Config

    init() throws {
        do {
            let baseUrl = wiltonFilesDir.appendingPathComponent("stdlib", isDirectory: true)
            var paths = [String: String]()
            let packagesFile = baseUrl.appendingPathComponent("wilton-requirejs/wilton-packages.json")
            let text = try readFileToString(packagesFile)
            paths["example"] = wiltonFilesDir.appendingPathComponent("app").absoluteString
            let packages = try wiltonFromJson(text, [Config.RequireJS.Package].self)
            self.config = Config(baseUrl.absoluteString, paths, packages)
        } catch {
            throw WiltonException("GetWiltoncallConfig: Error retrieving Wilton config, message: [\(error)]");
        }
    }

    func call(_ data: String) throws -> String {
        return wiltonToJson(self.config)
    }

    private class Config : Codable {
        private let defaultScriptEngine: String = "rhino"
        private let wiltonExecutable: String = MOBILE_UNSUPPORTED
        private let wiltonHome: String = MOBILE_UNSUPPORTED
        private let wiltonVersion: String = MOBILE_UNSUPPORTED
        private let requireJs: RequireJS
        private let environmentVariables: [String: String] = [String: String]()
        private let compileTimeOS: String = "mobile";
        private let debugConnectionPort: Int = -1;
        private let traceEnable: Bool = false;
        private let cryptCall: String = "";

        fileprivate init(_ baseUrl: String, _ paths: [String: String], _ packages: [RequireJS.Package]) {
            self.requireJs = RequireJS(baseUrl, paths, packages);
        }

        fileprivate class RequireJS : Codable {
            private let waitSeconds: Int = 0
            private let enforceDefine: Bool = true
            private let nodeIdCompat: Bool = true
            private let baseUrl: String
            private let paths: [String: String]
            private let packages: [Package]

            fileprivate init(_ baseUrl: String, _ paths: [String: String], _ packages: [Package]) {
                self.baseUrl = baseUrl;
                self.paths = paths;
                self.packages = packages;
            }

            fileprivate class Package : Codable {
                private let name: String!
                private let main: String!
            }
        }
    }
}
