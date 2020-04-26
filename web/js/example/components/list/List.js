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
    // id
    "module",
    // common
    "vue-require/router/push",
    "example/common/ui/image",
    "example/common/ui/highlight",
    // other
    "text!./List.html"
], function(
        module, // id 
        push, image, highlight, // common
        template // other
) {
    "use strict";

    function entryRowCss() {
        return {
            "row": true,
            "pt-2": true,
            "bg-primary": false
        };
    }

    function entryLabelCss() {
        return {
            "text-primary": true,
            "border-bottom": true,
            "h4": true,
            "font-weight-bold": false,
            "text-light": false
        };
    }

    function entryDescriptionCss() {
        return {
            "col": true,
            "text-muted": true,
            "text-light": false
        };
    }

    function createEntries(items) {
        var res = [];
        for (var i = 0; i < items.length; i++) {
            var it = items[i];
            var en = {
                label:it.label,
                description: it.description,
                path: it.path,
                rowCss: entryRowCss(),
                labelCss: entryLabelCss(),
                descriptionCss: entryDescriptionCss(),
                arrowSvg: "list-arrow.svg"
            };
            res.push(en);
        }
        return res;
    }

    return function(items) {
        this.template = template;

        this.data = function() {
            return {
                module: module,

                entries: createEntries(items)
            };
        },

        this.methods = {
            image: image,

            pushEntry: function(en) {
                highlight(function() {
                    en.rowCss["bg-primary"] = true;
                    en.labelCss["text-light"] = true;
                    en.descriptionCss["text-muted"] = false;
                    en.descriptionCss["text-light"] = true;
                    en.arrowSvg = "list-arrow_white.svg";
                }, function() {
                    en.rowCss["bg-primary"] = false;
                    en.labelCss["text-light"] = false;
                    en.descriptionCss["text-muted"] = true;
                    en.descriptionCss["text-light"] = false;
                    en.arrowSvg = "list-arrow.svg";
                    push(en.path);
                });
            }
        };
    };

});
