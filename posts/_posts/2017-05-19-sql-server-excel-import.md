---
layout: post
title: Importing data from Excel to SQL Server
relativeroot: ../../../../
category: posts
alt_excerpt: Importing excel data to SQL Server using SSMS requires a correct version of the Microsoft Access Database Engine Component.
---

Importing excel data to SQL Server using SSMS Import and Export Wizard requires the Microsoft Access Database Engine Component.

- 2010 version: <https://www.microsoft.com/en-us/download/details.aspx?id=13255>
- 2007 version: <https://www.microsoft.com/en-us/download/details.aspx?id=23734>

If you are getting an error stating "the 'microsoft.ace.oledb.12.0' provider is not registered on the local machine", try the 2007 version of the driver.
More information: <https://social.msdn.microsoft.com/Forums/en-US/1d5c04c7-157f-4955-a14b-41d912d50a64/how-to-fix-error-the-microsoftaceoledb120-provider-is-not-registered-on-the-local-machine>

1. Right-click the database node in SSMS, select Tasks -> Import Data...
2. Choose Microsoft Excel as the Data source
3. Choose SQL Server Native Client as the Destination and click through the rest of the wizard.
