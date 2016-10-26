---
layout: post
title: TypeScript & IntelliSense in Visual Studio
relativeroot: ../../../../
category: posts
alt_excerpt: Resolved "cannot find module" IntelliSense errors when using TypeScript in Visual Studio
---

I had some trouble getting intellisense to recognise types from `node_modules\@types` in a React & ASP.NET Core web application (I used the aspnetcore_spa yeoman generator from <https://github.com/aspnet/JavaScriptServices>).
The project would compile and run fine but intellisense was giving errors such as `Cannot find module 'react'` and `Cannot find name 'fetch'`.

At first I tried installing the typings manually but that resulted in duplicate type definitions (the typings cli installs the types to the `typings` directory instead of ´node_modules\@types`).

However, the resolution was simply to install the [TypeScript Tools](https://visualstudiogallery.msdn.microsoft.com/833221aa-2e48-4065-ac55-c3a083560fe0) for Visual Studio (Tools -> Extensions and Updates -> Online -> Visual Studio Gallery -> search for "typescript", e.g. "TypeScript 2.0.3 for Visual Studio 2015").

If you're getting similar build errors as well, you may need to add `typeRoots` into `tsconfig.json` under `compilerOptions` as well, but that was not necessary in my case.

{% highlight json %}
"typeRoots": [
  "node_modules/@types"
]
{% endhighlight %}

Additionally, tslint complained (in addition to some interface naming issues) about missing typedefs in lambda expressions within JSX code. The resolution for this was to add a `tslint.json` file to the project root with the following contents:

{% highlight json %}
{
  "extends": ["tslint:latest", "tslint-react"],
  "rules": {
    "jsx-no-lambda": true
  }
}
{% endhighlight %}

Source: <https://github.com/palantir/tslint-react>
