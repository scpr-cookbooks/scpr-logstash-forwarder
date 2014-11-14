
default.scpr_logstash_forwarder.ssl_path  = "/etc"

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