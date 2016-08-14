---
layout: document
title: Docker Deployment
description: Notes on docker container deployment.
modified: 2016-08-14 23:59:00
relativeroot: ../../
permalink: documents/docker-deployment
type: document
tags:
- Docker
- Deployment
- Orchestration
category: documents
published: true
hidden: true
---

TODO separate orchestration, cluster management, cloud computing etc.

TODO CoreOS fleet: cluster management or container management?

TODO https://www.linux.com/news/8-open-source-container-orchestration-tools-know

Deployment Options
==================

Running containers in production seriously requires using some orchestration platform tools to "herd the cattle". There are three different types of deployment platforms:

 - IaaS: provision VMs and deploy an orchestration platform yourself
 - CaaS: deploy containers directly to the service. Orchestration is taken care of.
 - PaaS: deploy applications. The platform takes care of containerization.

Most CaaS and PaaS offerings have their own take on what container orchestration should look like and they provide/require different sets of tools.
Deploying on IaaS requires setting up an orchestration platform yourself.
There are also PaaS solutions that you deploy yourself either on top of IaaS or in your own datacenter.

## Orchestration Platforms

 - Docker Swarm
 - Google Kubernetes
 - DC/OS / Mesosphere / Mesos / Marathon TODO how do these relate to each other?

## IaaS

The benefit of running on IaaS is that the whole solution can be deployed in the same way on any service provider or in a private datacenter.

Generally, you provision VMs directly on an IaaS provider or in the datacenter and deploy an orchestration solution on top of the VMs.
You can also use a cloud computing platform in the middle to form a PaaS of your own.

## CaaS

 - https://www.kontena.io/pricing
 - Coreos Tectonic (Kubernetes)
 - Azure Container Service ACS (DC/OS or Swarm)
 - Amazon EC2 Container Service ECS
 - Google Container Engine GKE (Kubernetes)

## PaaS

- IBM Bluemix
  - Based on CloudFoundry
- OpenShift
- Google Cloud Platform

## Cloud Platforms

- OpenShift Origin
  - Open source of OpenShift version that you deploy yourself
- Cloud Foundry
  - https://docs.cloudfoundry.org/concepts/diego/diego-architecture.html
- OpenStack (IaaS really?)
  - Has the Magnum service for running container orchestration platforms
  - Can run also OpenShift Origin, Cloud Foundry etc.
  - TODO https://blog.openshift.com/openshift-origin-vs-openstack/

Compose
=======

Swarm
=====

https://docs.docker.com/engine/swarm/
https://docs.docker.com/engine/swarm/swarm-tutorial/
