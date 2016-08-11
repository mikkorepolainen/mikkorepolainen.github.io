---
layout: document
title: Azure WebApps
description: Notes about using Azure Stream Analytics
modified: 2016-08-11 23:59:00
relativeroot: ../../
permalink: documents/azure-streamanalytics
type: document
tags:
- Stream Analytics
- Azure
category: documents
published: true
hidden: true
---

Links
=====

- REST API https://msdn.microsoft.com/en-us/library/azure/dn835031.aspx
- PowerShell https://azure.microsoft.com/en-us/documentation/articles/stream-analytics-monitor-and-manage-jobs-use-powershell/
- Management SDK https://azure.microsoft.com/en-us/documentation/articles/stream-analytics-dotnet-management-sdk/
- Query examples https://azure.microsoft.com/en-us/documentation/articles/stream-analytics-stream-analytics-query-patterns/
- Pricing https://azure.microsoft.com/en-us/pricing/details/event-hubs/
- Tumbling windows http://www.desertislesql.com/wordpress1/?p=961
- Scaling https://azure.microsoft.com/en-us/documentation/articles/stream-analytics-scale-jobs/

Notes
======

- tolerance windows cause delay
- not an option for real time event traffic
- different windows require separate jobs (each have an uptime cost)
