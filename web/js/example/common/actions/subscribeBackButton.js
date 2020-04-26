/*
 * Copyright 2020, Innotera, ltd
 */

define([
    "vue-require/router/pushBack",
    "vue-require/websocket/withSock",
    "wilton/web/wsClient",
    "example/common/store/checkActionError"
], function(pushBack, withSock, wsClient, checkActionError) {
    "use strict";

    return function(context) {
        withSock(function(err, sock) {
            if(checkActionError(err)) return;
            wsClient.subscribe(sock, "back", function(err) {
                if(checkActionError(err)) return;
                pushBack();
            });
        });
    };
});
