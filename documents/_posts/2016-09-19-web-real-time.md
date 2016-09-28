---
layout: document
title: Real-time Web Technologies
description: Notes about real-time web technologies and two-way communication on the web
modified: 2016-09-19 23:59:00
relativeroot: ../../
permalink: documents/real-time-web-tech
type: document
tags:
- WebSockets
- Long Polling
- Server-Sent Events
- EventSource
- Event Streaming
- WebHooks
- WebRTC
category: documents
published: true
hidden: true
---

TODO WebHooks, WebRTC
TODO https://www.leggetter.co.uk/2015/12/18/real-time-data-fundamentals.html
TODO https://github.com/leggetter/realtime-web-technologies-guide/blob/master/guide.md
TODO https://en.wikipedia.org/wiki/Comet_(programming)
TODO https://en.wikipedia.org/wiki/PubSubHubbub
TODO backplane options for multi-instance scenarios

# Resources

 - [An overview of realtime libraries and frameworks](https://deepstream.io/blog/realtime-framework-overview/)
 - [Real-time web technologies guide](https://www.leggetter.co.uk/real-time-web-technologies-guide/)
 - [Push: SSE vs WebSockets](http://streamdata.io/blog/push-sse-vs-websockets/)
 - [Benchmark: Server-Sent Events vs polling](http://streamdata.io/blog/benchmark-server-sent-events-versus-polling/)

TODO http://dsheiko.com/weblog/websockets-vs-sse-vs-long-polling/
TODO http://stackoverflow.com/questions/18799364/webrtc-vs-websockets-if-webrtc-can-do-video-audio-and-data-why-do-i-need-web
TODO https://docs.google.com/document/d/1idl_NYQhllFEFqkGQOLv8KBK8M3EVzyvxnKkHl4SuM8/edit
TODO https://www.youtube.com/watch?v=p2HzZkd2A40

TODO why not SSE https://news.ycombinator.com/item?id=9419920
TODO https://github.com/jpignata/blog/blob/master/articles/server-sent-events.md

TODO push frameworks https://azure.microsoft.com/en-us/documentation/articles/notification-hubs-aspnet-backend-windows-dotnet-wns-notification/

# Technologies

 - WebSockets
 - Long Polling (COMET)
 - Server-Sent Events (EventSource)
 - WebRTC
 - Forever Frame (COMET)
 - TODO Pub/Sub
    - TODO Protocols
    - TODO Caches
    - TODO https://nchan.slact.net/
 - TODO Webhooks & Firehose
 - TODO WAMP https://en.wikipedia.org/wiki/Web_Application_Messaging_Protocol
    - http://wamp-proto.org/ http://wamp-proto.org/why/ https://github.com/wamp-proto

# Frameworks

 - SignalR
 - Event Streaming FWs

# Server-Sent Events (EventSource)

 - Server has endpoint that streams messages to subscribers (one-way)
 - Persistent http connection optimized for this purpose
 - Polls every 3 seconds? Configurable?
 - Text-based format with optional type information
 - Client uses the EventSource interface (javascript) to subscribe to the stream or only to messages of certain type
 - Response content type must be "text/event-stream"?

 - [Not ubiquitous](http://caniuse.com/#search=eventsource) but can be used on older browsers using a polyfill (e.g. [this one](https://github.com/Yaffle/EventSource/)

 - [What is Server-Sent Events](http://streamdata.io/blog/server-sent-events/)
 - [MDN: Using server-sent events](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events)
    - https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events (polyfills listed here also)
 - [W3C: Server-Sent Events](https://www.w3.org/TR/eventsource/)
 - [w3schools](http://www.w3schools.com/html/html5_serversentevents.asp)
 - [html5rocks](http://www.html5rocks.com/en/tutorials/eventsource/basics/)
 - [HTML Living Standard](https://html.spec.whatwg.org/multipage/comms.html#server-sent-events)
 - [Using HTML5 Server-Sent Events with JSON and ASP.NET MVC](http://blogs.microsoft.co.il/gilf/2012/04/10/using-html5-server-sent-events-with-json-and-aspnet-mvc/)
 - [Streaming data with ASP.NET WEB API and pushcontentstream](http://gigi.nullneuron.net/gigilabs/streaming-data-with-asp-net-web-api-and-pushcontentstream/)
 - [HTML5 and Server-Sent Events](http://dsheiko.com/weblog/html5-and-server-sent-events)
 - [Native HTML5 push notifications with ASP.NET Web API and Knockout.js](http://www.strathweb.com/2012/05/native-html5-push-notifications-with-asp-net-web-api-and-knockout-js/)
 - [Server-Sent Event Notifications with HTML5](https://www.igvita.com/2011/08/26/server-sent-event-notifications-with-html5/)
 - [HTML5 Server-Sent Events](https://www.jayway.com/2012/05/11/html5-server-sent-events/)
 - [Server-sent events](https://en.wikipedia.org/wiki/Server-sent_events) List of libraries here
 - [When server-sent events (SSE) is much better choice than websocket](http://dotsandbrackets.com/when-sse-is-much-better-choice-than-websocket/)
 - https://www.sitepoint.com/real-time-apps-websockets-server-sent-events/
 - http://html5doctor.com/server-sent-events/
 - http://techbrij.com/real-time-chart-html5-push-sse-asp-net-web-api
 - https://blogs.msdn.microsoft.com/henrikn/2012/04/23/recent-asp-net-web-api-updates-april-24/ (Scroll down to Push Content)
 - http://stackoverflow.com/questions/12992242/webapi-and-html5-sse
 - https://www.justinribeiro.com/chronicle/2014/04/09/sse-asp-net-mvc-double-message/
 - http://www.c-sharpcorner.com/UploadFile/manish1231/learn-html5-part-3-server-sent-events-apis/
 
## Security

 - http://stackoverflow.com/questions/20324657/eventsource-sse-server-sent-svents-security
 - http://stackoverflow.com/questions/28176933/http-authorization-header-in-eventsource-server-sent-events
 - http://stackoverflow.com/questions/27898622/server-sent-events-stopped-work-after-enabling-ssl-on-proxy

## Client polyfills

 - https://github.com/Yaffle/EventSource/
 - https://github.com/remy/polyfills/blob/master/EventSource.js
 - https://github.com/rwaldron/jquery.eventsource
 - https://github.com/amvtek/EventSource

# SignalR

 - https://blogs.msdn.microsoft.com/webdev/2013/11/14/azure-web-site-now-supports-websockets/
 - http://www.asp.net/signalr/overview/getting-started/introduction-to-signalr
   - http://www.asp.net/signalr/overview/getting-started/tutorial-getting-started-with-signalr
   - http://www.asp.net/signalr/overview/getting-started/tutorial-high-frequency-realtime-with-signalr
   - http://www.asp.net/signalr/overview/getting-started/real-time-web-applications-with-signalr
 - http://www.asp.net/signalr/overview/guide-to-the-api/handling-connection-lifetime-events
 - http://www.asp.net/signalr/overview/deployment
   - http://www.asp.net/signalr/overview/deployment/tutorial-signalr-self-host
   - http://www.asp.net/signalr/overview/deployment/using-signalr-with-azure-web-sites
 - http://www.asp.net/signalr/overview/guide-to-the-api
   - http://www.asp.net/signalr/overview/guide-to-the-api/hubs-api-guide-server
   - http://www.asp.net/signalr/overview/guide-to-the-api/hubs-api-guide-server#multiplehubs
   - http://www.asp.net/signalr/overview/guide-to-the-api/hubs-api-guide-net-client
   - http://www.asp.net/signalr/overview/guide-to-the-api/hubs-api-guide-javascript-client
   - http://www.asp.net/signalr/overview/guide-to-the-api/working-with-groups
 - http://www.asp.net/signalr/overview/performance
 - Interesting question: http://stackoverflow.com/questions/22771162/can-multiple-instances-of-signalr-be-configured-to-use-a-different-message-bus-f
 - http://sravi-kiran.blogspot.fi/2013/09/ABetterWayOfUsingAspNetSignalRWithAngularJs.html
    - https://dzone.com/articles/better-way-using-aspnet Mirror
 - https://www.sitepoint.com/build-real-time-signalr-dashboard-angularjs/
 - https://azure.microsoft.com/en-us/blog/introduction-to-websockets-on-windows-azure-web-sites/
 - http://www.asp.net/signalr/overview/security/introduction-to-security
 - http://www.asp.net/signalr/overview/security/hub-authorization
 - http://henriquat.re/server-integration/signalr/integrateWithSignalRHubs.html
 - https://www.sitepoint.com/real-time-apps-websockets-server-sent-events/
 - http://www.asp.net/signalr/overview/guide-to-the-api/hubs-api-guide-javascript-client
 - http://henriquat.re/server-integration/signalr/integrateWithSignalRHubs.html
 - http://developer.telerik.com/featured/whats-the-buzz-a-real-time-chat-room-with-telerik-ui-and-signalr/
 - https://blog.3d-logic.com/2015/03/29/signalr-on-the-wire-an-informal-description-of-the-signalr-protocol/
 - http://techbrij.com/jquery-flot-signalr-asp-net-mvc-chart

## Persistent Connections (using without hubs)

 - https://github.com/SignalR/SignalR/wiki/QuickStart-Persistent-Connections
 - https://github.com/SignalR/SignalR/wiki/PersistentConnection
 - http://stackoverflow.com/questions/21512587/signalr-2-0-2-creating-persistentconnection
 - https://pepitosolis.wordpress.com/2013/11/27/signalr-2-0-persistentconnection-example/

## Selective updates

 - https://www.simple-talk.com/dotnet/asp-net/selective-updates-with-asp-net-signalr/
 - http://www.asp.net/signalr/overview/guide-to-the-api/mapping-users-to-connections
 - http://stackoverflow.com/questions/37377396/signalr-send-message-to-specific-client
 - http://stackoverflow.com/questions/19522103/signalr-sending-a-message-to-a-specific-user-using-iuseridprovider-new-2-0

## Scaling

 - http://www.asp.net/signalr/overview/performance/scaleout-in-signalr
 - http://www.asp.net/signalr/overview/performance/scaleout-with-windows-azure-service-bus
 - http://www.asp.net/signalr/overview/performance/scaleout-with-redis
 - http://www.asp.net/signalr/overview/performance/scaleout-with-sql-server
 - https://github.com/mdevilliers/SignalR.RabbitMq
 - https://roycornelissen.wordpress.com/2013/03/11/an-nservicebus-backplane-for-signalr/
    - https://github.com/roycornelissen/signalr.nservicebus
 - http://blog.jaywayco.co.uk/signalr-superhero-scale-out-in-azure/
 - http://scottcodes.net/signalr-load-balancing

## Security

- http://www.asp.net/signalr/overview/security
- http://www.asp.net/signalr/overview/security/introduction-to-security
- http://www.asp.net/signalr/overview/security/hub-authorization
- http://www.asp.net/signalr/overview/security/persistent-connection-authorization

Custom (e.g. claims) authorization http://www.asp.net/signalr/overview/security/hub-authorization#custom

http://www.asp.net/signalr/overview/security/introduction-to-security#groupsecurity:

Do not use groups as a security mechanism

Groups are a convenient way of collecting related users, but they are not a secure mechanism for limiting access to sensitive information.
This is especially true when users can automatically rejoin groups during a reconnect.
Instead, consider adding privileged users to a role and limiting access to a hub method to only members of that role.
For an example of restricting access based on a role, see [Authentication and Authorization for SignalR Hubs](http://www.asp.net/signalr/overview/security/hub-authorization).
For an example of checking user access to groups when reconnecting, see [Working with groups](http://www.asp.net/signalr/overview/guide-to-the-api/working-with-groups).

## Multitenancy

 - https://apprenda.com/blog/a-multi-tenant-real-time-app-with-apprenda-and-signalr/
 - https://social.msdn.microsoft.com/Forums/en-US/4b07a59d-fc86-4b7a-86ab-af07fa2ee684/signalr-notifications-to-an-specific-user-for-multi-tenant-application?forum=lightswitch
 - http://www.asp.net/signalr/overview/guide-to-the-api/working-with-groups


## Client side libraries

 - [AngularJS] https://github.com/JustMaier/angular-signalr-hub


# Redis Publish/subscribe

 - http://redis.io/topics/pubsub
 - http://webd.is/
 - https://www.toptal.com/go/going-real-time-with-redis-pubsub
 - http://stackoverflow.com/questions/6437741/how-to-use-servicestack-redis-in-a-web-application-to-take-advantage-of-pub-su

# Forum posts

 - http://stackoverflow.com/questions/9537641/node-js-socket-io-vs-signalr-vs-c-sharp-websocket-server

# WebSocket Frameworks/server side libraries

deepstream.io

 - https://deepstream.io/
 - https://deepstreamhub.com/

socket.io

SignalR

 - http://www.asp.net/signalr/overview/getting-started/introduction-to-signalr
 - https://www.simple-talk.com/dotnet/asp-net/asp-net-signalr-old-fashioned-polling-just-done-better/
 - https://www.npmjs.com/package/angular-signalr-hub
 - http://kevgriffin.com/why-should-asp-net-developers-consider-signalr-for-all-projects/
 - http://www.hanselman.com/blog/AsynchronousScalableWebApplicationsWithRealtimePersistentLongrunningConnectionsWithSignalR.aspx

SuperWebSocket

# Event Streaming Frameworks

getstream.io
