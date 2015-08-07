
default.scpr_logstash_forwarder.version   = "0.3.1-1scpr"
default.scpr_logstash_forwarder.ssl_cert  = "/etc/logstash-forwarder.crt"

default.scpr_logstash_forwarder.databag       = "certs"
default.scpr_logstash_forwarder.databag_item  = "logstash_forwarder"

default.scpr_logstash_forwarder.server    = nil

default.scpr_logstash_forwarder.files.syslog = {
  paths: [
    "/var/log/syslog",
    "/var/log/auth.log",
    "/var/log/kern.log"
  ],
  fields: {
    type: "syslog"
  }
}

#----------

include_attribute "logstash-forwarder"

default['logstash-forwarder']['logstash_servers'] = [node.scpr_logstash_forwarder.server]
default['logstash-forwarder']['config_path']      = "/etc/logstash-forwarder/forwarder.conf"
default['logstash-forwarder']['ssl_ca']           = node.scpr_logstash_forwarder.ssl_cert