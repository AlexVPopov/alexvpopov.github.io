---
layout: post
title: "Install Postgresql 9.2.4 on OS X Mountain Lion"
date: 2013-09-02 13:54
comments: true
categories: Rails, PSQL
---
# A quick way to get Postgres to work with your existing Rails app

There are plenty of instructions for installing PSQL on OS X Mountain Lion such as [this](https://coderwall.com/p/1mni7w) or [this](http://metacog.elijames.org/post/28333408639/setting-up-a-development-environment-on-mountain-lion). The problem here is that as of Mountain Lion Postgres opens a socket in `/var/pgsql_socket`, which is different from previous versions.<!-- more --> As a result, when you try to start Postgres with `psql` in the shell, you'll get an error message, similar to:

{% codeblock [PSQL starting error] %}
psql: could not connect to server: Permission denied
    Is the server running locally and accepting
    connections on Unix domain socket "/var/pgsql_socket/.s.PGSQL.5432"?
{% endcodeblock %}

The links I mentioned above provide a possible solution to this problem. You could also try the varios suggestions in [Stackoverflow](http://stackoverflow.com/search?q=.s.PGSQL.5432). Alas, I had no luck with any of them, but this is what saved my day:

1. Install the [Postgress App](http://postgresapp.com/):
    * [Download the latest version](http://postgresapp.com/download).
    * Unarchive it.
    * Drag-and-drop Postgres.app to your Applications folder
2. Amend your PATH by running this in the shell: 

    `export PATH="/Applications/Postgres.app/Contents/MacOS/bin:$PATH"`
2. Start the Postgres.app from your Applications folder. You should be seeing a black elephant in the menu bar.

3. Create a role with the same name as the one you have specified in your `database.yml` file with these commands
    * `psql` to startthe psql.
    * Create the role with `CREATE ROLE <username> SUPERUSER LOGIN;`.
    * `\q` to quit the psql shell.

4. After that run these commands to recreate the development and environment databases of your app:
    * `rake:db:create:all`
    * `rake:db:migrate`
    * `rake:db:migrate RAILS_ENV=test`

You should be good to go.

P.S. Also check out this [#342 Migrating to PostgreSQL](http://railscasts.com/episodes/342-migrating-to-postgresql?view=asciicast) Railscast for a full guide on migrating from SQLite to Postgres and this [Stackoverflow question](http://stackoverflow.com/questions/11092807/installing-postgresql-on-ubuntu-for-ruby-on-rails) for similar instructions for Ubuntu.


