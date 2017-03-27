---
layout: document
title: Windows Authentication in ASP.NET Core
description: Using Windows Authentication in ASP.NET Core Web Applications
modified: 2017-03-27 23:59:00
relativeroot: ../../
permalink: documents/aspdotnet-core-windows-authentication
type: document
tags:
- ASP.NET Core
- Windows Authentication
category: documents
published: true
hidden: false
---

Note that some of the content does not apply to RC1 or earlier versions and may not apply to later versions either.

# General

 - <https://docs.asp.net/en/latest/security/authentication/index.html>
 - <https://blogs.msdn.microsoft.com/webdev/2016/03/11/first-look-authentication-in-asp-net-core/>
 - <https://docs.asp.net/en/latest/fundamentals/servers.html>
 - <https://docs.asp.net/en/latest/publishing/iis.html>
 - <https://github.com/aspnet/Announcements/issues/204>
 
# Enable Windows Authentication

The server running the application must be configured to enable windows authentication and disable anonymous authentication.
If anonymous authentication is enabled, then it will be used by default and no user information is collected or required.

## Hosting Options

 - IIS + Kestrel: Windows authentication is configured in IIS (or `Properties\launchSettings.json` when debugging with Visual Studio and IIS Express).
 - WebListener: Windows authentication is configured in web host builder programmatically.

At the time of writing, windows authentication only works when the server is hosted on the Windows platform (IIS and WebListener are Windows-only).

Take a look at [ASP.NET Core Hosting]({% post_url 2016-10-29-aspdotnet-core-hosting %}) for setting up either hosting option.

Sources:

 - <https://docs.asp.net/en/latest/fundamentals/servers.html>

### WebListener

When using WebListener, you need to set up the authentication scheme in WebListener options in `Program.cs`:

{% highlight c# %}
using System.IO;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Net.Http.Server;

public static void Main(string[] args)
{
	var host = new WebHostBuilder()
		.UseWebListener(options =>
		{
			options.ListenerSettings.Authentication.Schemes = AuthenticationSchemes.NTLM; // <--
			options.ListenerSettings.Authentication.AllowAnonymous = false; // <--
		})
		.UseStartup<Startup>()
		.Build();

	host.Run();
}
{% endhighlight %}

Note: installing package `Microsoft.Net.Http.Server` from NuGet is required for accessing the AuthenticationSchemes class.

Sources:

- <https://github.com/aspnet/Announcements/issues/204>
- <http://stackoverflow.com/questions/37694211/windows-authentication-with-asp-net-core>

### IIS Integration

When using IIS Integration (Express or not), there are some configuration options that you can tweak.
Add configuration in `Startup.cs` in the `ConfigureServices` method:

{% highlight c# %}
services.Configure<IISOptions>(options => {
	//options.AuthenticationDescriptions holds a list of allowed authentication schemes
	options.AutomaticAuthentication = true;
	options.ForwardClientCertificate = true;
	options.ForwardWindowsAuthentication = true;
});
{% endhighlight %}

All three options default to `true` at least when running on IIS Express through Visual Studio.

Source: <https://docs.asp.net/en/latest/fundamentals/servers.html>

### IIS Express (when Debugging from Visual Studio)

In visual studio, right-click into the project properties and select the Debug tab.
Check "Enable Windows Authentication" and uncheck "Enable Anonymous Authentication"

The values are stored in `Properties\launchSettings.json`:

{% highlight json %}
{
  "iisSettings": {
    "windowsAuthentication": true,
    "anonymousAuthentication": false,
    ...
  },
  ...
}
{% endhighlight %}

Making this change also forces `forwardWindowsAuthToken` to `true` in `web.config` (`aspNetCore`-element under `system.webServer`) each time you start the app in debug mode.

### IIS

Enable windows authentication in IIS application host configuration file which can be found in the `system32\inetsrv` directory.

NOTE: IIS Express application configuration file lives in `$(solutionDir)\.vs\config\applicationhost.config`<sub>[source](http://stackoverflow.com/questions/4762538/iis-express-windows-authentication)</sub> when using Visual Studio 2015 (or `%userprofile%\documents\iisexpress\config\applicationhost.config` or somewhere else when using an earlier version).
TODO not verified using IIS Express directly. The configuration does not affect the behaviour of IIS Express when debugging through Visual Studio.

The correct section can be found in configuration -> system.webServer -> security -> authentication -> windowsAuthentication.

The configuration should look as follows.

{% highlight xml %}
<windowsAuthentication enabled="true">
    <providers>
        <add value="Negotiate" />
        <add value="NTLM" />
    </providers>
</windowsAuthentication>
{% endhighlight %}

TODO May have to remove the `Negotiate` provider as per <http://stackoverflow.com/questions/36946304/using-windows-authentication-in-asp-net>?

Windows authentication can also be enabled using the Internet Information Services Manager:
Go to the site's Authentication settings, enable Windows Authentication and disable Anonymous Authentication.

Make sure that the `forwardWindowsAuthToken` is set to `true` in `web.config` (`aspNetCore`-element under `system.webServer`).

Sources:

- <https://docs.asp.net/en/latest/publishing/iis.html>
- <http://www.codeproject.com/Tips/1022870/AngularJS-Web-API-Active-Directory-Security>
- <http://stackoverflow.com/questions/4762538/iis-express-windows-authentication>
- <http://stackoverflow.com/questions/36946304/using-windows-authentication-in-asp-net>
- <http://www.danesparza.net/2014/09/using-windows-authentication-with-iisexpress/>

# Identity Impersonation

TODO For accessing further resources such as an SQL DB or other APIs with windows authentication.

Sources:

- <http://stackoverflow.com/questions/35180871/asp-net-core-1-0-impersonation>
- <https://aleksandarsimic.wordpress.com/2016/07/21/asp-net-core-1-0-iis-impersonation/>

# Accessing User Information

## CSHtml

You can access user identity in `.cshtml` files by using, for example:

{% highlight html %}
<pre>@Html.Raw(Json.Serialize(User, new Newtonsoft.Json.JsonSerializerSettings() { ReferenceLoopHandling = Newtonsoft.Json.ReferenceLoopHandling.Ignore }))</pre>
<p>Name: @User.Identity.Name</p>
<p>Authenticated: @User.Identity.IsAuthenticated</p>
{% endhighlight %}

If you need to access the HttpContext, you need to add the HttpContextAccessor service in `Startup.cs`:

{% highlight c# %}
public void ConfigureServices(IServiceCollection services)
{
  ...
  services.AddSingleton<IHttpContextAccessor, HttpContextAccessor>();
  ...
}
{% endhighlight %}

And in cshtml:

{% highlight html %}
@inject IHttpContextAccessor httpContextaccessor

<pre>@Html.Raw(Json.Serialize(HttpContextAccessor.HttpContext.User.Identity, new Newtonsoft.Json.JsonSerializerSettings() { ReferenceLoopHandling = Newtonsoft.Json.ReferenceLoopHandling.Ignore }))</pre>

{% endhighlight %}

Source: <http://stackoverflow.com/questions/38945678/access-cookie-in-layout-cshtml-in-asp-net-core>

## In MCV or WebAPI Controllers

{% highlight c# %}
var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
var userName = User.FindFirstValue(ClaimTypes.Name);
var userName2 = User.Identity.Name;
{% endhighlight %}

Requires package `Microsoft.AspNetCore.Identity`

Sources:

- <http://stackoverflow.com/questions/30701006/how-to-get-the-current-logged-in-user-id-asp-net-core>

## JavaScript

There is no way that I came across to get at the windows user information directly in JavaScript, except by injecting through script tags and cshtml.

Source: <http://stackoverflow.com/questions/3013692/getting-windows-username-with-javascript>

# Calling API Methods from JavaScript

Make sure you include credentials in calls, e.g. with `fetch`:

{% highlight javascript %}
fetch("/api/SampleData/WeatherForecasts", { credentials: 'include' })
  .then(response => { ... });
{% endhighlight %}

# Authorization By Group Membership

Local groups:

- Local groups are written without the domain part or prefixed with the host name: `<group>` or `<hostname>\<group>`.
- Built-in local groups (e.g. `BUILTIN\Administrators`) are not recognized by name.
  You have to write the corresponding SID instead.
- You can find out the SIDs by using the `PsGetSid` tool: <https://technet.microsoft.com/en-us/sysinternals/bb897417>.
- The `BUILTIN\Administrators` group is not recognized even when using the correct SID.  

Group membership shows as role membership in ASP.NET Core.
You can enforce group membership directly with the Authorize attribute, with an authorization policy, or programmatically in the controller methods.

## Authorize Attribute

Add `[Authorize(Roles = @"<domain>\<group>")]` attribute (or `[Authorize(Roles = @"<domain>\<group1>,<domain>\<group2>")]` for multiple allowed roles) to the controller or method.

Sources:

- <https://docs.asp.net/en/latest/security/authorization/roles.html>

## Authorization Policy

Add a new policy to service configuration in `ConfigureServices` method in `Startup.cs`:

{% highlight c# %}
services.AddAuthorization(options =>
{
  options.AddPolicy("RequireWindowsGroupMembership", policy => policy.RequireRole(@"<domain>\<group>"));  
});
{% endhighlight %}

To get the required group name from settings, add the group name into `appsettings.json` (note the double backslashes):

{% highlight json %}
{
  "Logging": {
    ...
  },
  "WindowsGroup": "<domain>\\<group>"
}
{% endhighlight %}

Then read it in when configuring authorization:

{% highlight c# %}
services.AddAuthorization(options =>
{
  var windowsGroup = Configuration.GetValue<string>("WindowsGroup");
  options.AddPolicy("RequireWindowsGroupMembership", policy =>
  {
    policy.RequireAuthenticatedUser(); // Policy must have at least one requirement
    if (windowsGroup != null)
      policy.RequireRole(windowsGroup);
  });
});
{% endhighlight %}

Use a comma-separated string for multiple allowed roles: `<domain>\<group1>,<domain>\<group2>`.

Finally, add the authorize-attribute on the controller or method: `[Authorize(Policy = "RequireWindowsGroupMembership")]`

Sources:

- <https://docs.asp.net/en/latest/security/authorization/roles.html>

The policy syntax allows for more elaborate authorization scenarios with custom requirements, such as activity/permission-based authentication

- <https://docs.asp.net/en/latest/security/authorization/policies.html>
- <https://lostechies.com/derickbailey/2011/05/24/dont-do-role-based-authorization-checks-do-activity-based-checks/>
- <http://benjamincollins.com/blog/practical-permission-based-authorization-in-asp-net-core/>
- <http://benfoster.io/blog/asp-net-identity-role-claims>

## Programmatically

Check for role membership in controller method and return 403 Forbidden status code if not authorized.

{% highlight c# %}
[HttpGet("[action]")]
public IActionResult SomeValue()
{
  if (!User.IsInRole(@"Domain\Group")) return StatusCode(403);
  return Ok("Some Value");
}
{% endhighlight %}

Note that the return type of the method must be `IActionResult`.

# Browser Settings

If you need automatic windows authentication, then you may have to enable it specifically in the client browser

 - IE (TODO verify same works in EDGE)
    - Advanced -> Enable Integrated Windows Authentication in Internet Options
	- Security -> Local intranet -> Custom level -> User Authentication -> Automatic logon / Prompt for user name and password
 - Chrome
    - Chrome uses settings in Windows' internet options so the IE options should suffice<sub>[source](http://stackoverflow.com/questions/36946304/using-windows-authentication-in-asp-net)</sub>
 - Firefox
    - about:config -> network.automatic-ntlm-auth.trusted-uris -> add url of application

Sources:

- <http://www.codeproject.com/Tips/1022870/AngularJS-Web-API-Active-Directory-Security>
- <http://stackoverflow.com/questions/36946304/using-windows-authentication-in-asp-net>

# Different Domain or No Domain Binding

TODO Does not work with or without VPN connection on remote site (flashes a new console window and dies instantly, unable to capture error message)

If you are developing on a computer that is not bound to a domain, or is bound to a different domain that the app should authenticate against, you can run the server like so:

`runas /netonly /user:<user> "<command> <args...>"`

where `<user>` is `domain\username` or `username@domain`.

IIS: you must establish trust between the two domains to be able to run app pools under a user in different domain than the server.

IIS: does this work at all when running as network service??

Sources:

- <http://codebetter.com/jameskovacs/2009/10/12/tip-how-to-run-programs-as-a-domain-user-from-a-non-domain-computer/>
- <http://stackoverflow.com/questions/4762538/iis-express-windows-authentication>
- <http://stackoverflow.com/questions/5331206/how-to-run-iisexpress-app-pool-under-a-different-identity>
- <http://stackoverflow.com/questions/22058645/authenticate-against-a-domain-using-a-specific-machine/22060458#22060458>
- <https://forums.iis.net/t/1213147.aspx?How+I+can+run+IIS+app+pool+by+domain+account+>
- <https://blogs.msdn.microsoft.com/ssehgal/2009/06/23/running-iis6-app-pools-under-a-domain-account-identity/>
