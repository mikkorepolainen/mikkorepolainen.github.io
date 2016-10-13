---
layout: post
title: .NET WebAPI 2 NoCacheAttribute
relativeroot: ../../../../
category: posts
---

Attribute for preventing .NET WebAPI 2 GET requests from being cached on the client, namely IE11 which uses aggressive caching.
Affects all clients, not only IE11.

<script src="https://gist.github.com/mikkorepolainen/a5bb38b510b472008dcc37d6766898c2.js"></script>

Usage: Either decorate individual API methods with `[NoCache]` or globally:

{% highlight c# %}
...
public static class WebApiConfig
{
    public static void Register(HttpConfiguration config)
    {
        config.Filters.Add(new NoCacheAttribute());
        ...
{% endhighlight %}


Sources:

 - <http://stackoverflow.com/questions/16971831/better-way-to-prevent-ie-cache-in-angularjs>
 - <https://codewala.net/2015/05/25/outputcache-doesnt-work-with-web-api-why-a-solution/>
