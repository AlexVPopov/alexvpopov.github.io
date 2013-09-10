require 'bundler/setup'
require 'sinatra/base'

#############
# add caching from http://status200.me/blog/2013/05/04/free-and-fast-blogging-with-octopress/
#############

require 'dalli'
require 'rack-cache'
require 'memcachier'

use Rack::Cache,
  verbose: true,
  metastore:   Dalli::Client.new,
  entitystore: "file:tmp/cache/rack/body"

use Rack::Static,
  :urls => ["/assets", "/images", "/javascripts", "/stylesheets", "/media" ],
  :root => 'public',
  :cache_control => 'public, max-age=2592000'

#############
# add caching
#############

# The project root directory
$root = ::File.dirname(__FILE__)

class SinatraStaticServer < Sinatra::Base

  get(/.+/) do
    send_sinatra_file(request.path) {404}
  end

  not_found do
    send_file(File.join(File.dirname(__FILE__), 'public', '404.html'), {:status => 404})
  end

  def send_sinatra_file(path, &missing_file_block)
    file_path = File.join(File.dirname(__FILE__), 'public',  path)
    file_path = File.join(file_path, 'index.html') unless file_path =~ /\.[a-z]+$/i
    File.exist?(file_path) ? send_file(file_path) : missing_file_block.call
  end

end

run SinatraStaticServer
