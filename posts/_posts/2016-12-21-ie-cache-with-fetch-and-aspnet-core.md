---
layout: post
title: IE Cache problem when using JavaScript fetch and ASP.NET Core Web API
relativeroot: ../../../../
category: posts
alt_excerpt: Prevent IE from aggressively caching fetch results
---

When working on a web application using ASP.NET Core and React, I had a problem with IE 11 not refreshing the UI when changes were made, unless the entire page was refreshed with F5.
After a bit more testing I found out that IE caches the results of each fetch request to the API by default when no cache headers are explicitly set on the API side.
In Chrome the app worked as expected.

I found two options for resolving the issue: preventing caching on the client side by using request headers, or adding cache control headers in the API.
Both options resolve the issue, but you can have more granular control if done on the client side.
I chose to add the headers in the API.

<b>Client side headers</b>

Add cache headers in the fetch parameters object:

{% highlight javascript %}
let headers = new Headers();
headers.append('pragma', 'no-cache');
headers.append('cache-control', 'no-cache');
fetch("/api/...", { headers: headers })...
{% endhighlight %}

You can also try adding `cache: 'no-cache'` to the fetch parameters object but I didn't observe any effect.

- <https://hacks.mozilla.org/2016/03/referrer-and-cache-control-apis-for-fetch/>

<b>API headers</b>

Just add `[ResponseCache(Location = ResponseCacheLocation.None, NoStore = true)]` to the attributes of each `HttpGet` method or the entire controller.
Perhaps the best option would be to provide more accurate headers from the server, reflecting the current state or rate of change of the data, but I don't have time to implement that now.

- <https://docs.microsoft.com/en-us/aspnet/core/performance/caching/response>
