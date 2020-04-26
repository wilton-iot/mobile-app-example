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
    "vue-require/router/pushBack",
    "vue-require/router/pushForward",
    "example/common/ui/highlight",
    "example/common/ui/image",
    // local
    "text!./NavBar.html"
], function(
        module, // id
        push, pushBack, pushForward, highlight, image, // common
        template // local
) {
    "use strict";

    return function() {
        this.template = template;

        this.computed = {
            buttonSvg: function() {
                if (this.buttonHighlighted) {
                    return "menu_white.svg";
                } else if (this.$store.state.transient.canGoToMenu) {
                    return "menu.svg";
                } else {
                    return "menu_grey.svg";
                }
            },

            backSvg: function() {
                if (this.backHighlighted) {
                    return "back-arrow_white.svg";
                } else if (this.$store.state.transient.canGoBack) {
                    return "back-arrow.svg";
                } else {
                    return "back-arrow_grey.svg";
                }
            },

            forwardSvg: function() {
                if (this.forwardHighlighed) {
                    return "list-arrow_white.svg";
                } else if (this.$store.state.transient.canGoForward) {
                    return "list-arrow.svg";
                } else {
                    return "list-arrow_grey.svg";
                }
            }
        },

        this.data = function() {
            return {
                module: module,

                buttonCss: {
                    "example-img-inline-25": true,
                    "bg-primary": false
                },
                buttonHighlighted: false,

                backCss: {
                    "example-img-inline-25": true,
                    "bg-primary": false
                },
                backHighlighted: false,

                forwardCss: {
                    "example-img-inline-25": true,
                    "bg-primary": false
                },
                forwardHighlighed: false

            };
        },

        this.methods = {
            image: image,

            menu: function() {
                if (!this.$store.state.transient.canGoToMenu) {
                    return;
                }
                var self = this;
                highlight(function() {
                    self.buttonCss["bg-primary"] = true;
                    self.buttonCss["text-light"] = true;
                    self.buttonHighlighted = true;
                }, function() {
                    self.buttonCss["bg-primary"] = false;
                    self.buttonCss["text-light"] = false;
                    self.buttonHighlighted = false;
                    push("/menu");
                });
            },

            back: function() {
                if (!this.$store.state.transient.canGoBack) {
                    return;
                }
                var self = this;
                highlight(function() {
                    self.backCss["bg-primary"] = true;
                    self.backCss["text-light"] = true;
                    self.backHighlighted = true;
                }, function() {
                    self.backCss["bg-primary"] = false;
                    self.backCss["text-light"] = false;
                    self.backHighlighted = false;
                    pushBack();
                });
            },

            forward: function() {
                if (!this.$store.state.transient.canGoForward) {
                    return;
                }
                var self = this;
                highlight(function() {
                    self.forwardCss["bg-primary"] = true;
                    self.forwardCss["text-light"] = true;
                    self.forwardHighlighed = true;
                }, function() {
                    self.forwardCss["bg-primary"] = false;
                    self.forwardCss["text-light"] = false;
                    self.forwardHighlighed = false;
                    pushForward();
                });
            }
        };
    };
});
