---
layout: document
title: Docker Containers
description: Notes about docker container management with docker tools.
modified: 2016-05-15 23:59:00
relativeroot: ../../
permalink: documents/docker-containers
type: document
tags:
- Docker
- Containers
category: documents
published: true
hidden: true
---

Notes about managing and interacting with containers manually.
The information here is relevant only to development, testing, debugging (and perhaps really small production deployments).
Production workloads should be managed with the tools provided by the deployment platform in conjunction with logging/monitoring components used in the application architecture.

TODO restructure: theory first, then specifics of manual management?

Creating & Running Containers
=============================

Creating single containers manually is useful for development and testing purposes, or if running single (manually managed) containers in production without the need for an orchestration tool.
See TODO Separate document for deployment options and another for CI and CD.

https://docs.docker.com/engine/reference/commandline/run/

- `docker create --name <container-name> <image-name>` Create a container <sub>[reference](https://docs.docker.com/engine/reference/commandline/create/)</sub>.
- `docker start ... <container-name>` Start a created container <sub>[reference](https://docs.docker.com/engine/reference/commandline/start/)</sub>.
- `docker run -d --name <container-name> ... <image-name>` Shorthand for create + start <sub>[reference](https://docs.docker.com/engine/reference/commandline/run/)</sub>. Without `-d` connects to container and shows console output. Ctrl-C disconnects terminal but leaves container running.
- `docker ps --all` Show existing containers <sub>[reference](https://docs.docker.com/engine/reference/commandline/ps/)</sub>.

Running continuously
--------------------

Use the `--restart="<no, on-failure[:max-retry], always, unless-stopped>"` switch on create <sub>[reference](https://docs.docker.com/engine/reference/commandline/create/)</sub> or run <sub>[reference](https://docs.docker.com/engine/reference/run/#restart-policies-restart)</sub>.

The most useful value to use is `unless-stopped`, which will cause containers to be restarted on host reboot or docker daemon restart unless they have been stopped previously entered the stopped state (TODO only 0-exit status or all?). NOTE Using the `on-failure` option will not bring the containers back up after host reboot or docker daemon restart.
See [here](https://docs.docker.com/engine/reference/run/#restart-policies-restart) for a description for the other values.

Using the restart option is not recommended if using a process manager such as systemd. See [Automatically start containers](https://docs.docker.com/engine/admin/host_integration/). TODO why would I want to integrate with a process manager?

Short-Term Interactive Containers
---------------------------------

- `docker run -ti --rm <image-name>` The [`--rm`](https://docs.docker.com/engine/reference/run/#clean-up-rm) flag cleans up the container after exiting.

Resource management
===================

Memory, CPU etc.
----------------

Various options can be used to tweak the resources utilized by the container <sub>[reference](https://docs.docker.com/engine/reference/run/)</sub>. For example the following flags can be used with either the run or the create command.

- `-m "300M" --memory-swap "1G"` Set memory limit and limit for combined memory + swap (units b/k/m/g) <sub>[reference](https://docs.docker.com/engine/reference/run/#user-memory-constraints).
- `--cpu-shares=1024` CPU share weight (default 1024). By default all containers get an equal share. This option can be used to allocate CPU time differently. Applies only when CPU-intensive processes are running (containers compete on processing resources)<sub>[reference](https://docs.docker.com/engine/reference/run/#cpu-share-constraint)</sub>.

Environment Variables
---------------------

Set environment variables either in the image through the dockerfile or when creating the container (create/run).

### Dockerfile

Add environment variables by including `ENV ENV_VAR env_var_value` statements in the Dockerfile <sub>[reference](https://docs.docker.com/engine/reference/builder/#env)</sub>. The values can be used in some Dockerfile instructions as well by inserting `${ENV_VAR}` as parameter <sub>[reference](https://docs.docker.com/engine/reference/builder/#environment-replacement)</sub>.

### Run or Create

Add `-e ENV_VAR=env_var_value` to add or override an environment variable. <sub>[reference](https://docs.docker.com/engine/reference/run/#env-environment-variables)</sub>.

Exposing ports
--------------

TODO

-P, --publish-all             Publish all exposed ports to random ports
-p, --publish=[]              Publish a container's port(s) to the host

`docker run ... -p 8080:80 <image-name>` the `-p` option can be given multiple times for multiple ports.
`docker run ... -P <image-name>` allocates published ports automatically, use `docker port <image-name>` to see the external port number(s).

TODO https://docs.docker.com/engine/userguide/networking/default_network/dockerlinks/ Legacy -> should use networks instead?
TODO https://docs.docker.com/engine/userguide/networking/

Volumes
-------

Mount a directory (or file? TODO how does this work) either in the image (dockerfile)
or when creating the container (create/run).
Changes in the host are reflected immediately in the container.

### Dockerfile

```
VOLUME ["<path in container>"]
```

The mounted volume will show as a directory in the volumes directory, for example, `/var/lib/docker/volumes/<volume-name>/_data/` and is populated with files from the container image.
The `<volume-name>` is a generated identifier.
The path must be an absolute path.

The specified volume definition will be overridden if using the same `<path in container>` when creating/running the container using the `-v` option.

### Run or Create

- `-v <path in container>`: host volume name is generated, contents from image are copied over.
- `-v <name>:<path in container>` where name does not start with a forward slash: host volume name is `<name>` under volumes directory. If the named volume exists already, the contents will not be affected by image contents even when container is removed and re-created. Otherwise, the contents are copied over from the image.
- `-v <path on host>:<path in container>`: host volume in specified (absolute) path. Image contents are not copied on host at all (host directory completely overrides the directory in the container).

### Existing volumes

Stopping and removing the container does not remove the associated volumes (unless the [--rm](https://docs.docker.com/engine/reference/run/#clean-up-rm) switch was used when creating the container).
Removing the volume directory on the host is not sufficient either (it will still be mapped on the host). To remove a volume (or allow a named volume to be re-populated from the image when re-creating a container), use the `docker volume rm` command.

Use `docker volume ls` to list existing volume mappings

Use `docker volume rm <volume-name>` to remove volume

### Limiting volume Size

TODO https://github.com/docker/docker/issues/16670

Node
=====

https://hub.docker.com/_/node/
https://nodejs.org/en/docs/guides/nodejs-docker-webapp/
https://github.com/nodejs/docker-node/blob/master/docs/BestPractices.md
https://github.com/nodejs/docker-node

Managing and Monitoring Containers
===========================

Monitoring a Container
--------------------

- `docker inspect <container-name>` Show container information <sub>[reference](https://docs.docker.com/engine/reference/commandline/inspect/)</sub>.
- `docker stats <container-name> [<container-name> ...]` view runtime metrics for containers (CPU, Memory, Network) <sub>[reference](https://docs.docker.com/engine/reference/commandline/stats/)</sub>.

Logging from Containers
---------------------

### Logging options

STDIN, STDOUT and STDERR from the container are logged.
The json-file logging driver is used by default. This driver does not rotate logs by default and can therefore eventually fill the host filesystem (TODO right?).
The disk space used for logging via the json-file driver can be altered by using the `--log-opt` arguments. TODO https://github.com/docker/docker/pull/11485, https://github.com/docker/docker/issues/8911 and https://docs.docker.com/engine/admin/logging/overview/

TODO is there a limit that a container root file system can use? Running df seems to always return the same value for free disk space as the host.

Alternative log drivers can be used by specifying the `--log-driver <driver>` argument (and optionally driver-specific `--log-opt` arguments) when starting the docker daemon manually with the `docker daemon` command. The daemon-level log driver can be overridden by specifying the same arguments to `docker run` or `docker create`. <sub>[reference](https://docs.docker.com/engine/admin/logging/overview/)</sub>.

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

TODO check at least journald https://docs.docker.com/engine/admin/logging/journald/ and syslog drivers

TODO using alternative logging drivers with orchestration tools.

### Reading log entries

When using the json-file or the journald driver, the logs can be retrieved from an existing container using `docker logs <vm-name>` <sub>[reference](https://docs.docker.com/engine/reference/commandline/logs/)</sub>. This can be useful during development and testing.
TODO where are json-file and journald logs stored?

Useful arguments:

- Add `--tail=<no-of-lines>` to limit to a number of last entries.
- Add `--follow` (`-f`) flag to keep following the log (use Ctrl-C to exit).
- Add `--timestamps` (`-t`) to include timestamps as well.

NOTE The logs can also be retrieved using the remote API (TODO link to external instructions). TODO is this actually relevant?

TODO Otherwise, refer to the platform or logging driver -specific documentation on how to retrieve the generated log entries.

Stopping a Container
-----------------------

- `docker stop -t <timeout-seconds> <container-name>` Terminate container with SIGTERM and SIGKILL after timeout-seconds (default: 10 seconds) <sub>[reference](https://docs.docker.com/engine/reference/commandline/kill/)</sub>.
- `docker kill <container-name>` Terminate container with SIGKILL <sub>[reference](https://docs.docker.com/engine/reference/commandline/kill/)</sub>.
- `docker kill docker kill -s=<signal> <container-name>` Terminate the container by sending the specified signal to the process running in the container e.g. SIGQUIT for nginx <sub>[reference](https://docs.docker.com/engine/reference/commandline/kill/)</sub>.
- `docker rm <container-name>` Remove a containerL <sub>[reference](https://docs.docker.com/engine/reference/commandline/rm/)</sub>.

Accessing a Container's Terminal
--------------------------------

- `docker exec -it <container-name> bash` Open a terminal inside the container <sub>[reference](https://docs.docker.com/engine/reference/commandline/exec/)</sub>.
- `docker attach <container-name>` Attach terminal to container <sub>[reference](https://docs.docker.com/engine/reference/commandline/attach/)</sub>. NOTE detaching from the terminal does not work as described in the docs. For example, if attached from remote terminal with docker toolbox tools, Ctrl-C detaches the terminal instead of killing the process (Ctrl-P + Ctrl-Q does nothing). If ssh'ed on remote host and attached from there, the terminal cannot be detached or the process killed with any key combination (must kill the terminal). TODO container must be started with `-i` flag for this to work predictably? `-t` required as well? [see here](https://docs.docker.com/engine/quickstart/#running-an-interactive-shell)

TODO http://www.sebastien-han.fr/blog/2014/01/27/access-a-container-without-ssh/
TODO http://jpetazzo.github.io/2014/06/23/docker-ssh-considered-evil/

Update an Existing Container
------

### Change properties

- `docker rename <old-container-name> <new-container-name>` Rename a container <sub>[reference](https://docs.docker.com/engine/reference/commandline/rename/)</sub>

### Rebuild a Container From an Image

```
docker stop/kill <container>
docker rm <container>
docker build -t <container>
docker run ...
```
