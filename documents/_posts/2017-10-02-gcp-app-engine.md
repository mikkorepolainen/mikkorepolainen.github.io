---
layout: document
title: GCP App Engine Notes
description: Notes about Google Cloud Platform App Engine
modified: 2017-10-02 23:59:59
relativeroot: ../../
permalink: documents/gcp-app-engine
type: document
tags:
- GCP
- App Engine
category: documents
related:
published: true
hidden: true
---

# General

## Info and docs

- <https://cloud.google.com/appengine/>
- <https://cloud.google.com/appengine/docs/>
- <https://cloud.google.com/appengine/pricing>

## Services and Versions

Can have multiple versions of multiple *services* (AKA *modules*)

- Default service served at `https://<project id>.appspot.com/`
- Other services: `https://<service name>-dot-<project id>.appspot.com/`
- Specific versions: `https://<version>-dot-<service name>-dot-<project id>.appspot.com/`

Microservices with app engine: https://cloud.google.com/appengine/docs/standard/python/microservices-on-app-engine
 --> gradle modules == services?? https://github.com/GoogleCloudPlatform/appengine-modules-sample-java

## Environment Options

- [Migrating Services from the Standard Environment to the Flexible Environment](https://cloud.google.com/appengine/docs/flexible/java/migrating)
- [App Engine Flexible Environment for Users of App Engine Standard Environment](https://cloud.google.com/appengine/docs/flexible/java/flexible-for-standard-users)

### Standard

https://cloud.google.com/appengine/docs/standard/

Languages:

 - Python 2.7
 - Java 7, 8
 - PHP 5.5
 - Go 1.6


 - Standard environment has `google.appengine` APIs (not available in the flexible environment) for typical service requirements like the Google CLoud Datastore, though you can use the [Google Cloud client libraries](https://cloud.google.com/sdk/cloud-client-libraries) instead for increased portability.
 - Sandboxed (no local file system access, only whitelisted binary libraries)
 - Stateless lightweight HTTP services

### Flexible

https://cloud.google.com/appengine/docs/flexible/

Any language

> The Flexible Environment allows SSH access, allows disk
> writes, and supports third-party binaries (also allows stack
> customization and background processes).


No `google.appengine` APIs available, use the [Google Cloud client libraries](https://cloud.google.com/sdk/cloud-client-libraries) instead.

# Additional Features

- Task queues
- Scheduled tasks
- Blobstore
- Memcache
- Search
- Logs

# Pricing

TODO https://cloud.google.com/appengine/pricing

# Environment Configuration

Standard environment can be configured with the `appengine-web.xml` configuration file: <https://cloud.google.com/appengine/docs/standard/java/config/appref>

{% highlight xml %}
<?xml version="1.0" encoding="utf-8"?>
<appengine-web-app xmlns="http://appengine.google.com/ns/1.0">
  <module>service-1</module>
  <threadsafe>true</threadsafe>
</appengine-web-app>
{% endhighlight %}

If there is an `appengine-web.xml` file in project, then this is used to configure and deploy to the standard environment. TODO at least IntelliJ ignores app.yaml... might be IDE configuration issue though. And is this an IntelliJ-only construct???
To deploy to the flexible environment, you need to remove the appengine-web.xml file and create an app.yaml file instead with env set to flex.

- <https://cloud.google.com/appengine/docs/flexible/java/yaml-configuration-files>
- <https://cloud.google.com/appengine/docs/flexible/java/configuring-your-app-with-app-yaml>

Minimal app.yaml in root directory of a java project:

Flexible

{% highlight yaml %}
runtime: java
env: flex
service: service-1
# threadsafe: true
# automatic_scaling:
#   min_num_instances: 2
#   max_num_instances: 20
#   cpu_utilization:
#   target_utilization: 0.5
{% endhighlight %}

Standard

{% highlight yaml %}
runtime: java7
env: standard
service: service-1
# threadsafe: true
# instance_class: F1
# inbound_services:
#   - warmup
handlers:
  - url: /
    script: unused
  - url: '/.*/'
    script: unused
  - url: '/_ah/.*'
    script: unused
  - url: ".*\\.jsp"
    script: unused
# automatic_scaling:
#   min_idle_instances: automatic
#   max_idle_instances: automatic
#   min_pending_latency: automatic
#   max_pending_latency: automatic
{% endhighlight %}

For standard environment, change env value to `standard`.
If service is left out, then the app will be deployed as the `default` service.
Apparently the handlers section is not necessary for flex environment.
Commented out bits are default values assigned by GCP.

TODO image of result, point out different env. for different versions

# Deploying

## IntelliJ

- If Google App Engine Flexible framework is not autodetected, right-click on project -> Add Framework Support and check "Google App Engine Flexible" TODO cannot see it there though!
- File > Settings > Build, Execution, Deployment > Clouds -> Add new deployment profile by clicking +
- File -> Project Structure -> Facets -> Google App Engine Flexible -> Configure path to app.yaml or generate a new app.yaml
- File -> Project Structure -> Artifacts -> + -> Web Application: Archive -> for '<your exploded war>'

- <https://stackoverflow.com/questions/43073707/how-to-get-intellij-java-project-on-google-app-engine-flex>
- <https://cloud.google.com/tools/intellij/docs/deploy-flex>
- <https://cloudplatform.googleblog.com/2016/08/never-leave-your-Java-IDE-with-Google-Cloud-Tools-for-IntelliJ-plugin.html>
- <https://www.jetbrains.com/help/idea/getting-started-with-google-app-engine.html>

TODO Unable to change deployment mode to 

## Using the gcloud CLI tool

<https://cloud.google.com/appengine/docs/flexible/python/testing-and-deploying-your-app>

`gcloud app deploy [--no-promote] app.yaml`

`gcloud help app deploy`

TODO possible to use appengine-web.xml instead of app.yaml from cli?

# Samples & Tutorials

## Tutorial in Cloud Console using Cloud Shell

Java: `git clone https://github.com/GoogleCloudPlatform/appengine-try-java.git`

> mvn appengine:run
> mvn appengine:deploy
{: .terminal}

## Quickstarts

- [Java](https://cloud.google.com/java/quickstarts)
- [Go](https://cloud.google.com/go/quickstarts)
- [.NET Core](https://cloud.google.com/appengine/docs/flexible/dotnet/quickstart)
- [Node.js](https://cloud.google.com/nodejs/getting-started/hello-world)
- [Python](https://cloud.google.com/python/quickstarts)
- [Ruby](https://cloud.google.com/ruby/getting-started/hello-world)
- [PHP](https://cloud.google.com/php/quickstarts)

## Using the GCP Client library

See tutorials for supported languages on [GitHub](https://github.com/GoogleCloudPlatform/google-cloud-common).

TODO Using the app engine features (any available outside app engine, like task queues etc?)

- Tasks <https://cloud.google.com/appengine/docs/standard/python/taskqueue/push/creating-handlers>

