variable "prefix" {
  default = "bc"
}

variable "region" {
  description = "Deploy region"
  default = "westus2"
}

variable "swarm_admin_name" {
  description = "Username for the admin account on swarm01"
  default = "ubuntu"
}

variable "key_file" {
  description = "ssh key"
}

variable "manager_instance_type" {
  description = "Instance typr for manager nodes"
}

variable "dmarc_record" {
  description = "dmarc DNS TXT record"
}

variable "root_txt_record" {
  description = "TXT record for @"
}

variable "google_domainkey" {
  description = "TXT record for google domain key"
}