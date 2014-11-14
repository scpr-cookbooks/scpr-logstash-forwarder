#
# Cookbook Name:: scpr-logstash-forwarder
# Recipe:: default
#
# Copyright (c) 2014 Southern California Public Radio, All Rights Reserved.


# -- Add the repo -- #

include_recipe "apt"

apt_repository 'logstash-forwarder' do
  uri         'http://packages.elasticsearch.org/logstashforwarder/debian'
  components  ['stable','main']
  key         'http://packages.elasticsearch.org/GPG-KEY-elasticsearch'
end

# -- Install logstash-forwarder -- #

package 'logstash-forwarder'

file "/etc/init.d/logstash-forwarder" do
  action :nothing
end

service "logstash-forwarder-sysv" do
  action        :disable
  supports      [:stop, :start, :enable, :disable, :reload]
  service_name  "logstash-forwarder"
  provider      Chef::Provider::Service::Init::Debian
  notifies      :delete, "file[/etc/init.d/logstash-forwarder]"
end

# write an upstart config
cookbook_file "/etc/init/logstash-forwarder.conf" do
  action  :create
  mode    0644
end

service "logstash-forwarder" do
  action :start
  provider      Chef::Provider::Service::Upstart
  supports [:start,:stop,:restart]
end

#file "/etc/init.d/logstash-forwarder" do
#  action :delete
#end

# -- write our SSL files -- #

["logstash_forwarder.crt"].each do |f|
  cookbook_file "#{node.scpr_logstash_forwarder.ssl_path}/#{f}" do
    action  :create
    owner   'root'
    mode    0644
    notifies :restart, "service[logstash-forwarder]"
  end
end

# -- What files are we watching? -- #

files = []

node.scpr_logstash_forwarder.files.each_pair do |k,conf|
  files << conf.to_hash
end

# -- Set up our config file -- #

directory "/etc/logstash-forwarder" do
  action :create
  owner "root"
end

template "/etc/logstash-forwarder/forwarder.json" do
  action  :create
  owner   "root"
  mode    0644
  variables({
    ssl_path: node.scpr_logstash_forwarder.ssl_path,
    servers:  [node.scpr_logstash_forwarder.server],
    files:    files,
  })
  notifies :restart, "service[logstash-forwarder]"
end