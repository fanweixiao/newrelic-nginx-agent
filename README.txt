
nginx web server plugin for New Relic
Copyright (C) Nginx, Inc.


1. Preface

Visualize nginx web server performance with this plugin provided
by the original authors of nginx.

Collect and display key load metrics to track your nginx instances behavior.

This plugin was created by the original authors of nginx web server.
It allows to collect and report various important counters from an nginx
web server instance such as:

 * Active client connections
 * Idle (keepalive) client connections
 * Client connections accept rate, drop rate
 * Request rate

NGINX Plus customers will be able to use additional set of metrics
related to upstream monitoring (a number of servers, breakdown by state;
upstream servers connections; bandwidth usage; backend response rate,
breakdown by HTTP status code; healthchecks status).

Metrics will be charted in the New Relic User Interface and you will be able
to configure alerts based on the values reported by this plugin.

This plugin is distributed under 2-clause BSD-like license,
please refer to LICENSE file for details.


2. Requirements

In order to use this plugin, you must have an active New Relic account.

Plugin should work on any generic Unix environment with the following
software components installed:

  - Ruby (>= 1.8.7)

  - bundler for Ruby: https://github.com/carlhuda/bundler

  - nginx with ngx_http_stub_status module:
    http://wiki.nginx.org/HttpStubStatusModule (most nginx packages
    include this module by default)


3. Installation

To install all needed prerequisites for this plugin, you should run:

bundle install


4. Configuration

To configure this plugin you have to do the following:

  a) Add special stub_status location to your nginx configuration, e.g.:

    Example #1: listen on localhost, access from 127.0.0.1 only:

    server {
        listen 127.0.0.1:80;
        server_name localhost;

        location = /nginx_stub_status {
            stub_status on;
            allow 127.0.0.1;
            deny all;
        }
    }

    Example #2: listen on *:80, access limited by HTTP basic auth:

    server {
        listen 80;
        server_name example.com;

        location = /nginx_stub_status {
            stub_status on;
            auth_basic "nginx status";
            auth_basic_user_file /path/to/auth_file;
        }
    }

    Please follow this link to get more information about HTTP basic auth:
    http://nginx.org/en/docs/http/ngx_http_auth_basic_module.html

    Example #3: for NGINX Plus customers, listen on *:80, authorized access:

    server {
        listen 80;
        server_name example.com;

        location = /status {
            status;
            auth_basic "nginx status";
            auth_basic_user_file /path/to/auth_file;
        }
    }

    (see http://nginx.org/en/docs/http/ngx_http_status_module.html for details)

    Do not forget to reload nginx after changing the configuration.

  b) Copy config/newrelic_plugin.yml.in to config/newrelic_plugin.yml.

  c) Edit config/newrelic_plugin.yml:

    - insert your New Relic license key;

    - configure your nginx instances using the following parameters:
      - status_url (required): full URL pointing to stub_status output;
      - instance_name (optional): name of the instance as it will be
        appeared in the New Relic UI;
      - http_user, http_password (optional): credentials used for
        HTTP basic authorization.


5. Running the plugin

In order to check your configuration, you can launch the plugin
in foreground mode, with all output going to stdout:

  ./newrelic_nginx_agent

Carefully check plugin's output for any possible error messages.
In case of success, collected data should appear in the New Relic
user interface shortly after starting.

Plugin can also be started as a daemon using the following command:

  ./newrelic_nginx_agent.daemon start

In this case you can check its status by running

  ./newrelic_nginx_agent.daemon status

and stop it with

  ./newrelic_nginx_agent.daemon stop

You may want to create a symbolic link from /etc/init.d/ to the actual
location of newrelic_nginx_agent.daemon in order to start the agent
automatically at boot time.
