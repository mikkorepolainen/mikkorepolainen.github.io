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
- [Building REST APIs using ASP.NET Core and Entity Framework Core](https://chsakell.com/2016/06/23/rest-apis-using-asp-net-core-and-entity-framework-core/)

# Notes

## Scaffolding from an existing SQL Server db

Follow instructions here: <https://docs.efproject.net/en/latest/platforms/aspnetcore/existing-db.html>

`Scaffold-DbContext "<connection string>" [-Schemas <schema names>] Microsoft.EntityFrameworkCore.SqlServer -Force -OutputDir <dir>`

- <dir> will be created as a subdirectory in the project and used as namespace suffix in the generated model classes.
- The -Force flag is useful when regenerating the models because the models cannot be removed before re-scaffolding (the tool requires that the project can be compiled before scaffolding)
- It's probably a good practice to generate each schema in your model into a separate output dir, because if there are two tables with the same name in different schemas, the tool just appends ´1´ to the model name.

The context must also be modified each time you regenerate the models:

Remove:

{% highlight c# %}
protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
{
  #warning To protect potentially sensitive information in your connection string, you should move it out of source code. See http://go.microsoft.com/fwlink/?LinkId=723263 for guidance on storing connection strings.
  optionsBuilder.UseSqlServer(@"<connection string>");
}
{% endhighlight %}

Add:

{% highlight c# %}
public YourContext(DbContextOptions<YourContext> options) : base(options)
{ }
{% endhighlight %}

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

To prevent json serialization from converting from pascal to camel case (to keep your models in sync with e.g. your typescript interfaces), you can override the default contract resolver (DefaultContractResolver is not the default <https://github.com/aspnet/Announcements/issues/194>):

{% highlight C# %}
services.AddMvc()
  .AddJsonOptions(options => {
    options.SerializerSettings.ReferenceLoopHandling = Newtonsoft.Json.ReferenceLoopHandling.Ignore;
    options.SerializerSettings.ContractResolver = new DefaultContractResolver();
  });
{% endhighlight %}

Note that although this allows rapid development, returning the EF models directly is still probably a bad idea in all but the simplest scenarios: <http://juristr.com/blog/2012/10/lessions-learned-dont-expose-ef-entities-to-the-client-directly/>

## Related Data

Not possible to load related data using relation name as string: <https://docs.efproject.net/en/latest/querying/related-data.html>.
Lazy loading is not supported either.

TODO: separate document for web apis in core <https://docs.asp.net/en/latest/tutorials/first-web-api.html>
