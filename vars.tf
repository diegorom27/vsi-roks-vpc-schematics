variable ibm_region {
    description = "IBM Cloud region where all resources will be deployed"
    type        = string
    default = "us-south"

    validation  {
      error_message = "Must use an IBM Cloud region. Use `ibmcloud regions` with the IBM Cloud CLI to see valid regions."
      condition     = can(
        contains([
          "au-syd",
          "jp-tok",
          "eu-de",
          "eu-gb",
          "us-south",
          "us-east"
        ], var.ibm_region)
      )
    }
}
variable resource_group {
    description = "Name of resource group where all infrastructure will be provisioned"
    type        = string
    default     = "asset-development"

    validation  {
      error_message = "Unique ID must begin and end with a letter and contain only letters, numbers, and - characters."
      condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.resource_group))
    }
}

variable "name_vpc" {
  description = "vpc name region"
}

variable "name_subnet" {
  description = "subnet name region"
}

variable "subnet_zone" {
  default = "1"
  description = "number that identify the zone"
}

variable "ssh_keyname" {
  description = "ssh key name of region"
}

variable "rhel_image" {
  description = "Avaible RHEL image in the specific region"
  default = "r006-066a97dc-ebb3-4e44-8f1e-9ccae5b47e2a"
}

variable control_plane {
    description = "List of vm for control plane"
    type = list(object({
        hostname = string
        disks = list(number)
    }))
    default = [
        {
            hostname = "controlplane01-satellitedemo-cloud"
            disks    = [125]
        },
        {
            hostname = "controlplane02-satellitedemo-cloud"
            disks    = [125]
        },
        {
            hostname = "controlplane03-satellitedemo-cloud"
            disks    = [125]
        },
    ]
}

variable worker_nodes {
    description = "List of vm for worker nodes"
        type        = list(object({
            hostname     = string
            disks = list(number)
        }))
    default     = [
        {
            hostname     = "worker01-satellitedemo-cloud"
            disks = [100]
        },
        {
            hostname     = "worker02-satellitedemo-cloud"
            disks = [100]
        },
        {
            hostname     = "worker03-satellite-demo-cloud "
            disks = [100]
        }
    ]
}

variable ODF {
    description = "List of vm for ODF"
        type        = list(object({
            hostname     = string
            disks = list(number)
        }))
    default     = [
        {
            hostname     = "worker01-satellitedemo-cloud"
            disks = [100,100,300]
        },
        {
            hostname     = "worker02-satellitedemo-cloud"
            disks = [100,100,300]
        },
        {
            hostname     = "worker03-satellite-demo-cloud "
            disks = [100,100,300]
        }
    ]
}