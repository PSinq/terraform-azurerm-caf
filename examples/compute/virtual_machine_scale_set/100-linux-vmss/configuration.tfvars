global_settings = {
  default_region = "region1"
  prefix         = "test"
  regions = {
    region1 = "southeastasia"
  }
}

resource_groups = {
  rg1 = {
    name = "example-vmss-rg"
  }
}

managed_identities = {
  example_mi = {
    name               = "example_mi"
    resource_group_key = "rg1"
  }
}

vnets = {
  vnet1 = {
    resource_group_key = "rg1"
    vnet = {
      name          = "vmss"
      address_space = ["10.100.0.0/16"]
    }
    specialsubnets = {}
    subnets = {
      subnet1 = {
        name = "compute"
        cidr = ["10.100.1.0/24"]
      }
    }

  }
}


keyvaults = {
  kv1 = {
    name               = "vmsskv"
    resource_group_key = "rg1"
    sku_name           = "standard"
    creation_policies = {
      logged_in_user = {
        secret_permissions = ["Set", "Get", "List", "Delete", "Purge", "Recover"]
        key_permissions    = ["Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore", "Decrypt", "Encrypt", "UnwrapKey", "WrapKey", "Verify", "Sign", "Purge"]
      }
    }
  }
}

keyvault_keys = {
  key1 = {
    keyvault_key       = "kv1"
    resource_group_key = "rg1"
    name               = "vmsskey"
    key_type           = "RSA"
    key_size           = "2048"
    key_opts           = ["encrypt", "decrypt", "sign", "verify", "wrapKey", "unwrapKey"]
  }
}


diagnostic_storage_accounts = {
  # Stores boot diagnostic for region1
  bootdiag1 = {
    name                     = "vmssbootdiag1"
    resource_group_key       = "rg1"
    account_kind             = "StorageV2"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    access_tier              = "Cool"
  }
}

virtual_machine_scale_sets = {
  vmss1 = {
    resource_group_key = "rg1"
    boot_diagnostics_storage_account_key = "bootdiag1"
    os_type = "linux"
    keyvault_key = "kv1"

    vmss_settings = {
      linux = {
        name = "linux_vmss1"
        computer_name_prefix = "lnx"
        sku = "Standard_F2"
        instances = 1
        admin_username = "adminuser"
        disable_password_authentication = true
        provision_vm_agent = true
        priority = "Spot"
        eviction_policy = "Deallocate"
        ultra_ssd_enabled = false # required if planning to use UltraSSD_LRS

        upgrade_mode = "Manual" # Automatic / Rolling / Manual
        
        # rolling_upgrade_policy = {
        #   # Only for upgrade mode = "Automatic / Rolling "
        #   max_batch_instance_percent = 20
        #   max_unhealthy_instance_percent = 20
        #   max_unhealthy_upgraded_instance_percent = 20
        #   pause_time_between_batches = ""
        # }
        # automatic_os_upgrade_policy = {
        #   # Only for upgrade mode = "Automatic"          
        #   disable_automatic_rollback = false
        #   enable_automatic_os_upgrade = true
        # }


        os_disk = {
          caching = "ReadWrite"
          storage_account_type = "Standard_LRS"
          disk_size_gb = 128
          # disk_encryption_set_key = ""
          # lz_key = ""
        }

        identity = {
          # type = "SystemAssigned"
          type = "UserAssigned"
          managed_identity_keys = ["example_mi"]

          remote = {
            lz_key_name = {
              managed_identity_keys = []
            }
          }
        }

        source_image_reference = {
          publisher = "Canonical"
          offer     = "UbuntuServer"
          sku       = "18.04-LTS"
          version   = "latest"
        }

      }
    }

    network_interfaces = {
      nic0 = {
        # Value of the keys from networking.tfvars
        name                    = "0"
        primary                 = true
        vnet_key                = "vnet1"
        subnet_key              = "subnet1"
        
        enable_accelerated_networking = false
        enable_ip_forwarding    = false
        internal_dns_name_label = "nic0"
      }
    }
    

    data_disks = {
      data1 = {
        caching                 = "None" # None / ReadOnly / ReadWrite
        create_option           = "Empty" # Empty / FromImage (only if source image includes data disks)
        disk_size_gb            = "10"
        lun                     = 1
        storage_account_type    = "Standard_LRS" # UltraSSD_LRS only possible when > additional_capabilities { ultra_ssd_enabled = true }       
        disk_iops_read_write    = 100 # only for UltraSSD Disks
        disk_mbps_read_write    = 100 # only for UltraSSD Disks
        write_accelerator_enabled = false # true requires Premium_LRS and caching = "None"
        # disk_encryption_set_key = "set1"
        # lz_key = "" # lz_key for disk_encryption_set_key if remote
      }
    }

  }

vmss2 = {
    resource_group_key = "rg1"
    provision_vm_agent = true
    boot_diagnostics_storage_account_key = "bootdiag1"
    os_type = "windows"
    keyvault_key = "kv1"

    vmss_settings = {
      windows = {
        name = "win"
        computer_name_prefix = "win"
        sku = "Standard_F2"
        instances = 1
        admin_username = "adminuser"
        disable_password_authentication = true
        priority = "Spot"
        eviction_policy = "Deallocate"

        upgrade_mode = "Manual" # Automatic / Rolling / Manual
        
        # rolling_upgrade_policy = {
        #   # Only for upgrade mode = "Automatic / Rolling "
        #   max_batch_instance_percent = 20
        #   max_unhealthy_instance_percent = 20
        #   max_unhealthy_upgraded_instance_percent = 20
        #   pause_time_between_batches = ""
        # }
        # automatic_os_upgrade_policy = {
        #   # Only for upgrade mode = "Automatic"          
        #   disable_automatic_rollback = false
        #   enable_automatic_os_upgrade = true
        # }


        os_disk = {
          caching = "ReadWrite"
          storage_account_type = "Standard_LRS"
          disk_size_gb = 128
        }

        identity = {
          type = "SystemAssigned"
          managed_identity_keys = []
        }

        source_image_reference = {
          publisher = "Canonical"
          offer     = "UbuntuServer"
          sku       = "18.04-LTS"
          version   = "latest"
        }

      }
    }

    network_interfaces = {
      nic0 = {
        # Value of the keys from networking.tfvars
        name                    = "0"
        primary                 = true
        vnet_key                = "vnet1"
        subnet_key              = "subnet1"
        
        enable_accelerated_networking = false
        enable_ip_forwarding    = false
        internal_dns_name_label = "nic0"
      }
    }
    ultra_ssd_enabled = false # required if planning to use UltraSSD_LRS

    data_disks = {
      data1 = {
        caching                 = "None" # None / ReadOnly / ReadWrite
        create_option           = "Empty" # Empty / FromImage (only if source image includes data disks)
        disk_size_gb            = "10"
        lun                     = 1
        storage_account_type    = "Standard_LRS" # UltraSSD_LRS only possible when > additional_capabilities { ultra_ssd_enabled = true }       
        disk_iops_read_write    = 100 # only for UltraSSD Disks
        disk_mbps_read_write    = 100 # only for UltraSSD Disks
        write_accelerator_enabled = false # true requires Premium_LRS and caching = "None"
        # disk_encryption_set_key = "set1"
        # lz_key = "" # lz_key for disk_encryption_set_key if remote
      }
    }

  }

}