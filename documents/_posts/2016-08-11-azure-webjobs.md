---
layout: document
title: Azure WebJobs
description: Notes about developing WebJobs on Azure
modified: 2016-08-11 23:59:00
relativeroot: ../../
permalink: documents/azure-webjobs
type: document
tags:
- Azure
- WebJobs
category: documents
published: true
hidden: true
---

Continuous, scheduled or on-demand (run from the portal).

Continous jobs require that the web app hosting the job is configured with the "Always On" option (requires basic tier+), otherwise the job may be terminated when the app becomes idle [reference](https://azure.microsoft.com/en-us/documentation/articles/web-sites-configure/)

TODO Use cases: when to and when not to, alternatives


Dashboard
------------

Dashboard: access at https://yoursite.scm.azurewebsites.net/azurejobs

Scheduled WebJobs
----------------------

Minimum frequency - each minute - is not free. Other frequencies are free (hours, days etc.) [reference](https://azure.microsoft.com/en-us/documentation/articles/websites-dotnet-deploy-webjobs/).


General
=======

- https://github.com/projectkudu/kudu/wiki/Web-Jobs
- https://azure.microsoft.com/en-us/documentation/articles/web-sites-create-web-jobs/
- https://azure.microsoft.com/en-us/documentation/articles/websites-dotnet-webjobs-sdk/

Webjobs API: https://github.com/projectkudu/kudu/wiki/WebJobs-API

Singleton
=========

Continuous web jobs must sometimes run only on a single node even though there are more than one instance.
Examples: EventHub EventProcessorHost for a fixed

 - https://blogs.msdn.microsoft.com/waws/2014/05/19/how-to-run-a-continuous-webjob-as-a-singleton/
 - add the file to root (project root, set Copy to Output Directory property to Copy if newer)

Using with EventHub
===================

- http://stackoverflow.com/questions/36727808/any-example-of-webjob-using-eventhub
- https://github.com/Azure/azure-webjobs-sdk/wiki/EventHub-support

Graceful Shutdown
=============

 - http://blog.amitapple.com/post/2014/05/webjobs-graceful-shutdown/
 - https://github.com/projectkudu/kudu/wiki/Web-Jobs
 - http://stackoverflow.com/questions/27770547/notification-of-when-continuous-azure-webjob-is-stopping-for-noautomatictrigger
 - http://stackoverflow.com/questions/35166010/azure-triggered-webjob-detecting-when-webjob-stops
 - http://stackoverflow.com/questions/35166010/azure-triggered-webjob-detecting-when-webjob-stops
 - http://stackoverflow.com/questions/27770547/notification-of-when-continuous-azure-webjob-is-stopping-for-noautomatictrigger
 - https://github.com/Azure/azure-webjobs-sdk/blob/master/src/Microsoft.Azure.WebJobs.Host/WebjobsShutdownWatcher.cs
 - http://stackoverflow.com/questions/22429769/graceful-shutdown-of-azure-webjobs
 - http://stackoverflow.com/questions/24513448/how-to-prevent-azure-webjob-from-starting-up-after-publishing
 - 

Continuous/Timers
 - http://stackoverflow.com/questions/29625813/how-to-make-azure-webjob-run-continuously-and-call-the-public-static-function-wi

Timers (config, bug in old ver): http://stackoverflow.com/questions/34665763/azure-webjobs-timertrigger-not-triggering

Timer Samples
 - https://github.com/Azure/azure-webjobs-sdk-extensions/blob/master/src/ExtensionsSample/Samples/TimerSamples.cs

Queues, listen to poison messages: https://github.com/victorhurdugaci/AzureWebJobsSamples/tree/master/SendEmailOnFailure

Links
=====

- Hanselman hype [blog post](http://www.hanselman.com/blog/IntroducingWindowsAzureWebJobs.aspx).
- Creating a webjob [article](https://azure.microsoft.com/en-us/documentation/articles/websites-dotnet-webjobs-sdk-get-started/).
- WebJobs for queue storage [article](https://azure.microsoft.com/en-us/documentation/articles/websites-dotnet-webjobs-sdk-storage-queues-how-to/).
- Deployment (with or without a web app) [reference](https://azure.microsoft.com/en-us/documentation/articles/websites-dotnet-deploy-webjobs/).
- To enable webjobs dashboard when deployed alongside another web app, you need to put the AzureWebJobsDashboard connectionstring in the web app configuration through azure portal [reference](http://stackoverflow.com/questions/34124804/azurewebjobsdashboard-configuration-error).
- Web job published alongside another web app gets configuration settings also from the web app's configuration settings (web.config or overridden from the portal) [reference](http://blog.ploeh.dk/2014/05/16/configuring-azure-web-jobs/).
- Single Writer [reference](http://blog.ploeh.dk/2014/04/30/single-writer-web-jobs-on-azure/).
- Scheduled continuous polling [reference](http://blog.ploeh.dk/2014/09/25/faking-a-continuously-polling-consumer-with-scheduled-tasks/).
