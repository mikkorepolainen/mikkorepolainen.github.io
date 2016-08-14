---
layout: document
title: Azure WebApps
description: Notes about using Azure Event Hubs
modified: 2016-08-11 23:59:00
relativeroot: ../../
permalink: documents/azure-eventhubs
type: document
tags:
- Event Hubs
- Azure
category: documents
published: true
hidden: true
---

Links
=====

- https://azure.microsoft.com/en-us/documentation/articles/event-hubs-overview/
- https://azure.microsoft.com/en-us/documentation/articles/event-hubs-api-overview/
- http://blogs.biztalk360.com/understand-azure-event-hubs/
- http://prasad-pillutla.github.io/Prasadthinks/blog/2015/06/18/nuances-of-azure-event-hubs/
- https://blogs.msdn.microsoft.com/paolos/2014/12/01/how-to-create-a-service-bus-namespace-and-an-event-hub-using-a-powershell-script/
- https://social.msdn.microsoft.com/Forums/windowsserver/en-US/0934435e-c578-4d20-b9d9-30a572706007/eventhub-how-to-set-up-the-offset-when-using-eventprocessorhost-?forum=servbus
- https://blogs.msdn.microsoft.com/opensourcemsft/2015/08/08/choosing-between-azure-event-hub-and-kafka-what-you-need-to-know/

Best Practices
===========

- TODO best practice for reliable processing: use a persistent queue in between?

Checkpoints
-----------

- https://social.msdn.microsoft.com/Forums/windowsserver/en-US/0934435e-c578-4d20-b9d9-30a572706007/eventhub-how-to-set-up-the-offset-when-using-eventprocessorhost-?forum=servbus
  - Possible but works only on first request to partition ("blob lease obtained") -> must remove CG and related blob data and start over to reset.

Using with webjobs
------------------

- TODO best practices when using with webjobs, e.g. when should checkpoint
