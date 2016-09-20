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

# Technologies

 - WebSockets
 - Long Polling (COMET)
 - Server-Sent Events (EventSource)
 - WebRTC
 - Forever Frame
 - TODO Webhooks & Firehose

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
