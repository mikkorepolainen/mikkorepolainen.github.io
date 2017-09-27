---
layout: document
title: Using the Google Cloud CLI on docker
description: Using docker to run the Google Cloud command line interface
modified: 2017-09-27 23:59:59
relativeroot: ../../
permalink: documents/gcloud-cli-on-docker
type: document
tags:
- GCP
- Docker
category: documents
related:
published: true
---

**Create a container with a configuration volume**

`docker run -ti --name gcloud-config google/cloud-sdk:latest gcloud auth login`

Output:

> Go to the following link in your browser:
>
>    https://accounts.google.com/o/oauth2/auth?redirect_uri=...
>
>
> Enter verification code: _
{: .terminal}

Copy the address into your browser and log in with your google account. The sign in page should appear with a verification code.

{% include figure.html id="google-cloud-sdk-signin" url="images/google-cloud-sdk-signin.png" caption="Screenshot of the sign in web page." description="Screenshot of the sign in web page." %}

Copy the verification code into the terminal.
Once you authenticate successfully, credentials are preserved in the volume of the gcloud-config container.
The gcloud-config container is used only for importing the volume in further invocations.

The cloud sdk images and documentation can be found on dockerhub: <https://hub.docker.com/r/google/cloud-sdk/>

**Set project ID**

`docker run --rm -ti --volumes-from gcloud-config google/cloud-sdk gcloud config set project <project id>` (project id is in the format `<project name>-<some number>` e.g. myproject-181008)

**Execute commands**

e.g. to list compute instances, type

`docker run --rm -ti --volumes-from gcloud-config google/cloud-sdk:latest gcloud compute instances list` 

etc.
