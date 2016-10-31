---
layout: document
title: ASP.NET Core 1.0 Hosting
description: Hosting options for ASP.NET Core 1.0 Web Applications
modified: 2016-10-31 23:59:00
relativeroot: ../../
permalink: documents/aspdotnet-core-hosting
type: document
tags:
- ASP.NET Core
- Hosting
category: documents
published: true
hidden: true
---

Note that some of the content does not apply to RC1 or earlier versions and may not apply to later versions either.

# Publishing

Publish the application: `dotnet publish -c <Debug/Release>`.

The results are generated in `.\bin\<Debug/Release>\netcoreapp1.0\publish`.

To run the published application from command line, type `dotnet <name-of-dll> <arguments>` (without the `run` command).

Source: <https://docs.microsoft.com/fi-fi/dotnet/articles/core/tools/dotnet-publish>

# Hosting Options

 - Kestrel
 - IIS + Kestrel (Windows only)
 - WebListener (Windows only at the time of writing)

Sources:

 - <https://docs.asp.net/en/latest/fundamentals/servers.html>

## Kestrel

`Program.cs`: Add `UseKestrel` to `WebHostBuilder` as below:

{% highlight c# %}
using System.IO;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;

public static void Main(string[] args)
{
	var host = new WebHostBuilder()
		.UseKestrel() // <--
		.UseStartup<Startup>()
		.Build();

	host.Run();
}
{% endhighlight %}
 
## WebListener

Install Microsoft.AspNetCore.Server.WebListener from NuGet

`Program.cs`: add `UseWebListener` as below:

{% highlight c# %}
using System.IO;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Net.Http.Server; // <--

public static void Main(string[] args)
{
	var host = new WebHostBuilder()
		.UseWebListener() // <--
		.UseStartup<Startup>()
		.Build();

	host.Run();
}
{% endhighlight %}

Sources:

- <https://github.com/aspnet/Announcements/issues/204>

## IIS

This should work for both IIS Express and IIS version 7 and above

### Application

`Program.cs`: Add `UseKestrel` and `UseIISIntegration` to `WebHostBuilder` as below:

{% highlight c# %}
var builder = new WebHostBuilder()
  .UseConfiguration(config)
  .UseContentRoot(Directory.GetCurrentDirectory())
  .UseKestrel() // <--
  .UseIISIntegration() // <--
  .UseStartup<Startup>();
{% endhighlight %}

If you need to configure the specifics of IIS integration, add configuration in `Startup.cs` in the `ConfigureServices` method:

{% highlight c# %}
services.Configure<IISOptions>(options => {
	//options.AuthenticationDescriptions holds a list of allowed authentication schemes
	//options.AutomaticAuthentication = true;
	//options.ForwardClientCertificate = true;
	//options.ForwardWindowsAuthentication = true;
});
{% endhighlight %}

Add the following entries to the `tools` and `scripts` sections in `project.json` if not present:

{% highlight json %}
{
  ...,
  "tools": {
    ...,
    "Microsoft.AspNetCore.Server.IISIntegration.Tools": "1.0.0-preview2-final"
  },
  "scripts": {
    ...,
    "postpublish": "dotnet publish-iis --publish-folder %publish:OutputPath% --framework %publish:FullTargetFramework%"
  },
  ...
}
{% endhighlight %}

The `publish-iis` tool fills in the appropriate `processPath` and `arguments` in the `web.config` file behind the scenes when you run `dotnet publish`.

### Dependencies

Install the following dependencies on the target server:

- .NET 4.5.1
- .NET Core Windows Server Hosting bundle

### Application Pool

The application pool must have the `.NET Framework version` or `.NET CLR version` set to `No Managed Code`.
You can either configure the application specific pool that is created with the site, or pre-create a shared pool for ASP.NET Core apps (e.g. `AspNetCoreAppPool`).

`C:\Program Files\dotnet\` must be in the path and accessible by the application pool identity.
Search for `IIS AppPool\DefaultAppPool` in the local directory for the default ApplicationPoolIdentity unless using another identity for the pool.

Restart IIS afterwards.

If you're getting windows errors `Failed to start process with commandline ‘“dotnet” .\<app>.dll’, ErrorCode = ‘0x80070002’.` then restart the server as well.

### Deployment

Deploy the published directory structure from under `.\bin\<Debug/Release>\netcoreapp1.0\publish` into a new directory on the server. Add `logs` folder to the root of the directory.

In IIS Manager, create a new website (Sites -> Right-click -> Add Website).
Provide a site name, app pool (new site-specific pool or e.g. `AspNetCoreAppPool`), and the path to the deployment directory.
The app pool identity must also have full access to the deployment directory.

Sources:

- <https://docs.asp.net/en/latest/fundamentals/servers.html>
- <https://docs.asp.net/en/latest/publishing/iis.html>
- <https://github.com/dotnet/cli/issues/2135>
- <https://weblog.west-wind.com/posts/2016/Jun/06/Publishing-and-Running-ASPNET-Core-Applications-with-IIS>

# Enable All Three Options

{% highlight c# %}
public static void Main(string[] args)
{
	var config = new ConfigurationBuilder()
		.AddCommandLine(args)
		.AddEnvironmentVariables(prefix: "ASPNETCORE_")
		.Build();

	var server = config["server"] ?? "Kestrel";

	var builder = new WebHostBuilder()
		.UseConfiguration(config)
		.UseContentRoot(Directory.GetCurrentDirectory())
		.UseIISIntegration() // This declaration is a no-op if not run under IIS so it does not prevent running in self-hosted mode.
		.UseStartup<Startup>();

	if (string.Equals(server, "Kestrel", StringComparison.OrdinalIgnoreCase))
	{
		// IIS does not support WebListener: must run with Kestrel when hosting with IIS or IIS Express
		Console.WriteLine("Running with Kestrel.");

		builder.UseKestrel();
	}
	else if (string.Equals(server, "WebListener", StringComparison.OrdinalIgnoreCase))
	{
		// Kestrel does not support windows authentication: use WebListener or host on IIS or IIS Express
		Console.WriteLine("Running with WebListener.");

		builder.UseWebListener(options =>
		{
			options.ListenerSettings.Authentication.Schemes = AuthenticationSchemes.NTLM;
			options.ListenerSettings.Authentication.AllowAnonymous = false;
		});
	}

	var host = builder.Build();
	host.Run();
}
{% endhighlight %}

This way you can select the WebListener server by using the command line argument `--server=WebListener`.

If you want to debug also with Kestrel and WebListener, set up the profiles section in your `Properties/launchSettings.json` as follows:

{% highlight json %}
{
  ...
  "profiles": {
    "IIS Express": {
      "commandName": "IISExpress",
      "launchBrowser": true,
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    },
    "Kestrel": {
      "commandName": "Project",
      "launchBrowser": true,
      "commandLineArgs": "--server=Kestrel",
      "launchUrl": "http://localhost:5000/",
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    },
    "WebListener": {
      "commandName": "Project",
      "launchBrowser": true,
      "commandLineArgs": "--server=WebListener",
      "launchUrl": "http://localhost:5000/",
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    }
  }
}
{% endhighlight %}

Change the launchUrl ports accordingly if using non-default URL bindings. IIS Express uses a different port anyway so launchUrl is not required there.

Sources:

- <https://docs.asp.net/en/latest/fundamentals/servers.html>
- <http://andrewlock.net/configuring-urls-with-kestrel-iis-and-iis-express-with-asp-net-core/>
- <http://benfoster.io/blog/how-to-configure-kestrel-urls-in-aspnet-core-rc2>

# Configure URLs

You can simply add something like `.UseUrls("http://localhost:60000", "http://localhost:60001")` to `WebHostBuilder` in `Program.cs`.

You can also use an external `hosting.json` file:

## Separate File for Hosting URLs

Add a `hosting.json` file in the project:

{% highlight json %}
{
  "urls": "http://*:60000;http://localhost:60001"
}
{% endhighlight %}

Add base path and the external file in `ConfigurationBuilder` in `Program.cs`:

{% highlight c# %}
var config = new ConfigurationBuilder()
  .SetBasePath(Directory.GetCurrentDirectory()) // <--
  .AddJsonFile("hosting.json", optional: true) // <--
  .Build();
{% endhighlight %}

Add the external file also in the `include` section in your `project.json`:

{% highlight json %}
{
  ...,
  "publishOptions": {
	...,
    "include": [
	  ...,
	  "appsettings.json",
	  "web.config",
	  "hosting.json",
	  ...
	],
	...
  },
  ...
}
{% endhighlight %}

Source: <http://benfoster.io/blog/how-to-configure-kestrel-urls-in-aspnet-core-rc2>

## Permissions

With WebListener, you can only bind to localhost ports when running as a regular user, unless you have been specifically granted access to the port using something like `netsh http add urlacl url=http://<ip>:<port>/ user=<user>`<sub>[source](https://github.com/aspnet/Hosting/issues/503)</sub>.

TODO Administrators, Local Service, Network Service, specific premissions needed?

# Hosting in a Windows Service

TODO

Sources:

- <http://dotnetthoughts.net/how-to-host-your-aspnet-core-in-a-windows-service/>
