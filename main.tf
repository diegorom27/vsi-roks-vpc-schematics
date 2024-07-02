##############################################################################
# Terraform Providers
##############################################################################
terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      version = ">=1.19.0"
    }
  }
}
##############################################################################
# Provider
##############################################################################
# ibmcloud_api_key = var.ibmcloud_api_key

provider ibm {
    alias  = "primary"
    region = var.ibm_region
    max_retries = 20
}
##############################################################################
# Resource Group
##############################################################################

data ibm_resource_group group {
    provider = ibm.primary
    name = var.resource_group
}
##############################################################################
# Recuperar data de la SSH Key
##############################################################################

data "ibm_is_ssh_key" "sshkey" {
  provider = ibm.primary
  name = var.ssh_keyname
}
##############################################################################
# Recuperar data de la VPC primary
##############################################################################

data "ibm_is_vpc" "pr_vpc" {
  provider = ibm.primary
  name = var.name_vpc
}

##############################################################################
# Recuperar data de la subnet primary
##############################################################################

data "ibm_is_subnet" "pr_subnet" {
  provider = ibm.primary
  name = var.name_subnet
}

##############################################################################
# Control plane
# ibmcloud sl hardware create-options
# OS_RHEL_8_X_64_BIT_PER_PROCESSOR_LICENSING      REDHAT_8_64
##############################################################################


#resource "ibm_is_volume" "control_plane_storage" {
#    count =  3
#    name = "controlplane0${count.index + 1}.storage.satellite-demo.cloud"
#    zone       = "dal13"
#    profile = "5iops-tier"
#    capacity = 100
#}

resource "ibm_is_instance" "control_plane" {
    for_each = { for vm in var.control_plane : vm.hostname => vm }
    provider = ibm.primary
    name    = each.value.hostname
    profile = "bx2d-4x16"
    image = var.rhel_image

    primary_network_interface {
      subnet = data.ibm_is_subnet.pr_subnet.id
    }

    vpc       = data.ibm_is_vpc.pr_vpc.id
    zone      = "${var.ibm_region}-${var.subnet_zone}"
    keys      = [data.ibm_is_ssh_key.sshkey.id]
    resource_group = data.ibm_resource_group.group.id

    boot_volume{
        name = "boot-volume-${each.value.hostname}"
        size = 25
    }
}

locals {
  instance_ids = { for k, v in ibm_is_instance.control_plane : k => v.id }
}

locals {
  # Flatten to a list of maps where each map contains `hostname`, `disk_index`, and `disk_size`
  flattened_disks = flatten([
    for cp in var.control_plane : [
      for idx, size in cp.disks : {
        hostname = cp.hostname
        disk_index = idx
        disk_size = size
      }
    ]
  ])

  # Create a map with keys in the format of `hostname-disk_index`
  volume_attachment_map = {
    for disk in local.flattened_disks : "${disk.hostname}-${disk.disk_index}" => disk
  }
}

resource "ibm_is_instance_volume_attachment" "control_plane_storage" {
  for_each = local.volume_attachment_map

  instance                           = local.instance_ids[each.value.hostname]
  name                               = "storage-attachment-${each.key}"
  iops                               = 5
  capacity                           = each.value.disk_size
  delete_volume_on_attachment_delete = true
  delete_volume_on_instance_delete   = true
  volume_name                        = "storage-${each.key}"

  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}

##############################################################################
# Worker nodes
##############################################################################



##############################################################################
# ODF 
# profile bx2-8x32
##############################################################################
