---
layout: document
title: GCP Cloud Endpoints Notes
description: Notes about Google Cloud Platform Cloud Endpoints
modified: 2017-10-02 23:59:59
relativeroot: ../../
permalink: documents/gcp-cloud-endpoints
type: document
tags:
- GCP
- Cloud Endpoints
- App Engine
category: documents
related:
published: true
hidden: true
---

# General

<https://cloud.google.com/endpoints/>

TODO what means: Supports App Engine Standard or Flexible Environment, Compute Engine, Container Engine
JWT support (how?) -> Auth0/Firebase

API Framework choices: https://cloud.google.com/endpoints/docs/

- OpenAPI Specification
  - Use for JSON/REST APIs implemented on:
  - Google App Engine flexible environment
  - Google Compute Engine
  - Google Container Engine
  - Kubernetes
- Endpoints Frameworks
  - Use for JSON/REST APIs implemented on:
  - Google App Engine standard environment with Java
  - Google App Engine standard environment with Python
- gRPC
  - Use for gRPC APIs implemented on:
  - Google Compute Engine
  - Google Container Engine
  - Kubernetes

TODO http://www.planetjones.co.uk/blog/19-05-2013/google-app-engine-endpoints-with-java-maven-part1.html
TODO https://medium.com/google-cloud/secure-pubsub-push-with-cloud-endpoints-6a1adc36db9f