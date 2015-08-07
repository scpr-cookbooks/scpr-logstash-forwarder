#
# Cookbook Name:: scpr-logstash-forwarder
# Recipe:: default
#
# Copyright (c) 2014 Southern California Public Radio, All Rights Reserved.

# -- write our SSL Cert -- #

# find our databag item for the logstash-forwarder cert
cert = begin data_bag_item(node.scpr_logstash_forwarder.databag,node.scpr_logstash_forwarder.databag_item) rescue nil end

if cert
  file node.scpr_logstash_forwarder.ssl_cert do
    action  :create
    mode    0644
    content cert['cert']
    notifies :restart, "service[logstash-forwarder]"
  end
end

directory "/etc/logstash-forwarder" do
  action  :create
  owner   "root"
end

# -- Install logstash-forwarder -- #

include_recipe "logstash-forwarder"

# make sure all our installs get the same init file
cookbook_file "/etc/init.d/logstash-forwarder" do
  action    :create
  mode      0755
  source    "logstash-forwarder.sysv"
  notifies  :restart, "service[logstash-forwarder]"
end

# write our defaults file
template "/etc/default/logstash-forwarder" do
  action    :create
  mode      0644
  source    "logstash-forwarder.defaults.erb"
  notifies  :restart, "service[logstash-forwarder]"
end

# -- Transition from Upstart job -- #

file "/etc/init/logstash-forwarder.conf" do
  action  :nothing
  mode    0644
end

service "logstash-forwarder-upstart" do
  action        [:stop,:disable]
  provider      Chef::Provider::Service::Upstart
  service_name  "logstash-forwarder"
  supports      [:start,:stop,:restart,:enable,:disable]
  notifies      :delete, "file[/etc/init/logstash-forwarder.conf]"
end

# remove our old config file
file "/etc/logstash-forwarder/forwarder.json" do
  action :delete
end

# -- What files are we watching? -- #

# support attribute-based specs while we transition to the LWRP
node.scpr_logstash_forwarder.files.each_pair do |k,conf|
  log_forward k do
    paths   conf['paths']
    fields  conf['fields']
  end
end

