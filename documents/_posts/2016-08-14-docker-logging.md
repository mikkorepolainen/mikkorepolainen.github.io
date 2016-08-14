---
layout: document
title: Docker Logging
description: Logging from containers.
modified: 2016-08-14 23:59:00
relativeroot: ../../
permalink: documents/docker-logging
type: document
tags:
- Docker
- Logging
category: documents
published: true
hidden: true
---

Logging From Containers
======================

Docker logs STDIN, STDOUT and STDERR from the container automatically.

## Apps that log to file

TODO Options to retrieve

Logging Drivers
===============

Log drivers can be used by specifying the `--log-driver <driver>` argument (and optionally driver-specific `--log-opt` arguments) in docker daemon startup. The arguments can be given when starting the docker daemon manually with the `docker daemon` command or in the docker startup configuration file (e.g. `/etc/default/docker`) on the host (`DOCKER_OPTS` directive).
The daemon-level log driver can be overridden by specifying the same arguments to `docker run` or `docker create`. <sub>[reference](https://docs.docker.com/engine/admin/logging/overview/)</sub>.

- none	Disables any logging for the container. docker logs won’t be available with this driver.
- json-file	Default logging driver for Docker. Writes JSON messages to file.
- syslog	Syslog logging driver for Docker. Writes log messages to syslog.
- journald	Journald logging driver for Docker. Writes log messages to journald.
- gelf	Graylog Extended Log Format (GELF) logging driver for Docker. Writes log messages to a GELF endpoint like Graylog or Logstash.
- fluentd	Fluentd logging driver for Docker. Writes log messages to fluentd (forward input).
- awslogs	Amazon CloudWatch Logs logging driver for Docker. Writes log messages to Amazon CloudWatch Logs.
- splunk	Splunk logging driver for Docker. Writes log messages to splunk using HTTP Event Collector.
- etwlogs	ETW logging driver for Docker on Windows. Writes log messages as ETW events.
- gcplogs	Google Cloud Logging driver for Docker. Writes log messages to Google Cloud Logging.

JSON File
---------

The `json-file` logging driver is used by default.
The logs are stored on the host under the container directory `/var/lib/docker/containers/<container id>/<container-id>-json.log`.
This driver does not rotate logs by default and can therefore eventually fill the host filesystem.
Use the `--log-opt` arguments to configure log rotation <sub>[reference]( https://docs.docker.com/engine/admin/logging/overview/)</sub>. Another method is to use the linux logrotate tool on the host: create a rule for `/var/lib/docker/containers/*/*.log` like [here](https://sandro-keil.de/blog/2015/03/11/logrotate-for-docker-container/).

TODO check at least journald https://docs.docker.com/engine/admin/logging/journald/ and syslog drivers

TODO logging services in orchestration platforms?

TODO (r)syslog (filter, fwd to different file or external tcp or udp endpoint)
TODO spout gathers logs through docker API and forwards
TODO ELK
TODO file grab
