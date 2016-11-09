---
layout: document
title: Entity Framework Core
description: Entity Framework Core notes
modified: 2016-11-09 23:59:00
relativeroot: ../../
permalink: documents/dotnet-core-ef
type: document
tags:
- ASP.NET Core
- .NET Core
- EF Core
category: documents
published: true
hidden: true
---

# Resources

- [Entity Framework Core Docs](https://docs.efproject.net/en/latest/)
- [ASP.NET Core Application to Existing Database](https://docs.efproject.net/en/latest/platforms/aspnetcore/existing-db.html)
- [](https://chsakell.com/2016/06/23/rest-apis-using-asp-net-core-and-entity-framework-core/)

# Notes

## Class Libraries

It is not currently possible to isolate an EF Core solution to a class library: <https://docs.efproject.net/en/latest/miscellaneous/cli/dotnet.html#targeting-class-library-projects-is-not-supported>

## Connection Strings

- <https://docs.efproject.net/en/latest/miscellaneous/connection-strings.html>

## ASP.NET Core APIs

Returning EF model objects directly from ASP.NET Core APIs requires ignoring reference loop handling in JSON serializer settings (`Startup.cs`): <http://stackoverflow.com/questions/34290683/is-it-possible-to-get-complex-entity-framework-objects-from-a-rest-api-in-net-w>

{% highlight C# %}
services.AddMvc()
  .AddJsonOptions(options => {
    options.SerializerSettings.ReferenceLoopHandling = Newtonsoft.Json.ReferenceLoopHandling.Ignore;
  });
{% endhighlight %}

Then again it is a bad idea in all but the simplest scenarios: <http://juristr.com/blog/2012/10/lessions-learned-dont-expose-ef-entities-to-the-client-directly/>

TODO: separate document for web apis in core <https://docs.asp.net/en/latest/tutorials/first-web-api.html>
