---
layout: post
title: "Set up HTTP caching with Octopress"
date: 2013-09-06 18:25
comments: true
categories: Octopress, Tutorial, Optimization
keywords: cache, caching, memcache, memcached, memcachier, dalli, octopress
description: A tutorial for setting up HTTP cashing with an Octopress blog using the memcache system with dalli and memcachier gems.
published: false
---
## Speed up your Octopress blog by using memcached and Rake::Cache

Things to mention:

* http://redbot.org/? - RedBot for checking the cache settings on your site.
* [Caching Tutorial](http://www.mnot.net/cache_docs/) - caching tutorial for more info on how caching works
* [Things Caches Do](http://tomayko.com/writings/things-caches-do) - a caching tutorial by Ryan Tomayko, author of [Rake::Cache](http://rtomayko.github.io/rack-cache/ ) and co-founder of GitHub
* Based on [Free and Fast Blogging With Octopress, Rack::Cache, Newrelic, and Unicorn](http://status200.me/blog/2013/05/04/free-and-fast-blogging-with-octopress/)
* [Dalli](https://github.com/mperham/dalli) gem
* [Memcachier](https://www.memcachier.com/) and [memcachier](https://github.com/memcachier/memcachier-gem) gem
* If memcached is not installed locally, you'll most likely see `cache error: No server available` message in the `rake preview` console. Besides your styles will not load correctly, when running locally and you will have to reload a page several times to display properly.