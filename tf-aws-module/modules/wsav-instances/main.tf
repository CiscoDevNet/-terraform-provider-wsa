################################################################################
# Cisco WSA EC2 instance(s)
################################################################################
locals {
  instance_type = {
    "S100V" = ["m4.large", 250]
    "S300V" = ["c4.2xlarge", 1000]
    "S600V" = ["c4.4xlarge", 1000]
  }
}

resource "aws_instance" "wsav" {
  count = var.number_of_instances
  ami   = var.ami_id != null ? var.ami_id : data.aws_ami.wsav_ami[0].id
  instance_type = (
    var.ami_id != null ? var.instance_type :
    local.instance_type[var.wsa_model][0]
  )

  key_name = (
    var.create_key_pair ? aws_key_pair.generated_key[0].key_name :
    var.key_pair_name
  )

  root_block_device {
    volume_type = "gp2"
    volume_size = (
      var.volume_size != null ? var.volume_size :
      local.instance_type[var.wsa_model][1]
    )
  }

  # default interface
  associate_public_ip_address = (
    var.create_network_interfaces ? null : var.associate_public_ip_address
  )
  vpc_security_group_ids = (
    var.create_network_interfaces ? null : var.security_groups
  )
  subnet_id = (
    var.create_network_interfaces ? null : var.subnet_id[count.index]
  )

  # multiple netwwork interfaces
  dynamic "network_interface" {
    for_each = var.create_network_interfaces ? [1] : []
    content {
      network_interface_id = var.mgmt_network_interface[count.index]
      device_index         = 0
    }
  }

  dynamic "network_interface" {
    for_each = var.create_network_interfaces ? [1] : []
    content {
      network_interface_id = var.data_network_interface[count.index]
      device_index         = 1
    }
  }


  tags = var.wsav_tags

  provisioner "local-exec" {
    # usage: first_boot_config.py [-h] -hn HOSTNAME [-dh DATA_INTERFACE_HOSTNAME] [-di DATA_INTERFACE_IP] [-dm DATA_INTERFACE_NETMASK]
    #                             [-dg DATA_INTERFACE_GATEWAY_IP] [-tp TRAILBLAZER_PORT] [-us USERNAME] [-pw PASSWORD] -st SMART_LICENSE_TOKEN
    #                             [-sp SSW_PASSWORD] [-ne NOTIF_EMAIL] [-rl] [-ll {CRITICAL,ERROR,WARNING,INFO,DEBUG}]

    # optional arguments:
    #   -h, --help            show this help message and exit
    #   -hn HOSTNAME, --hostname HOSTNAME
    #                         public hostname
    #   -dh DATA_INTERFACE_HOSTNAME, --data_interface_hostname DATA_INTERFACE_HOSTNAME
    #                         data interface hostname
    #   -di DATA_INTERFACE_IP, --data_interface_ip DATA_INTERFACE_IP
    #                         data interface ip
    #   -dm DATA_INTERFACE_NETMASK, --data_interface_netmask DATA_INTERFACE_NETMASK
    #                         data interface netmask, eg: 16, 24 etc.
    #   -dg DATA_INTERFACE_GATEWAY_IP, --data_interface_gateway_ip DATA_INTERFACE_GATEWAY_IP
    #                         data interface gateway ip
    #   -tp TRAILBLAZER_PORT, --trailblazer_port TRAILBLAZER_PORT
    #                         Trailblazer port
    #   -us USERNAME, --username USERNAME
    #                         username (ex: admin)
    #   -pw PASSWORD, --password PASSWORD
    #                         Current password of device in base64 format (ex: aXJvbnBvcnQ=)
    #   -st SMART_LICENSE_TOKEN, --smart_license_token SMART_LICENSE_TOKEN
    #                         Smart License Registration Token
    #   -sp SSW_PASSWORD, --ssw_password SSW_PASSWORD
    #                         SSW password
    #   -ne NOTIF_EMAIL, --notif_email NOTIF_EMAIL
    #                         Notification email
    #   -rl, --release_license
    #                         Use this option without any value to release licences.
    #   -ll {CRITICAL,ERROR,WARNING,INFO,DEBUG}, --log_level {CRITICAL,ERROR,WARNING,INFO,DEBUG}
    #                         Log level. Possible values are [CRITICAL, ERROR, WARNING, INFO, DEBUG]

    command = "python ../../../scripts/python_scripts/first_boot_config/first_boot_config.py -st ${var.smart_license_token} -hn ${var.mgmt_interface_hostname[count.index]} -dh \"${var.data_interface_hostname[count.index]}\" -di \"${var.data_interface_private_ip[count.index]}\" -dm \"${var.data_interface_netmask[count.index]}\" -dg \"${var.data_interface_gateway_ip[count.index]}\" -sp ${var.ssw_password} -ne ${var.notification_email}"
  }

  # @TODO: Need some exploration about, how to use a variable
  #        in a destroy time provisioner. Normal input variables
  #        doesn't work here.
  #
  # provisioner "local-exec" {
  #   command = "python ../../scripts/python_scripts/first_boot_config/first_boot_config.py -hn ${var.public_domain_name} -pw ${var.ssw_password} --release_license"
  #   when = destroy
  # }
}

################################################################################
# WSAv AMI
################################################################################
data "aws_ami" "wsav_ami" {
  count       = var.ami_id != null ? 0 : 1
  most_recent = true // you can enable this if you want to deploy more
  owners      = ["238379942059"]

  filter {
    name   = "name"
    values = ["${var.wsa_version}-*-${var.wsa_model}*-AMI-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

################################################################################
# Create AWS Key pair
################################################################################

resource "tls_private_key" "auto_gen_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
  count     = var.create_key_pair ? 1 : 0
}

resource "aws_key_pair" "generated_key" {
  key_name = var.key_pair_name
  # Saving the public key "key_pair_name.pem" to AWS
  public_key = tls_private_key.auto_gen_key[count.index].public_key_openssh

  provisioner "local-exec" {
    # Saving the private key "key_pair_name.pem" to current directory
    command = <<-EOT
      echo '${tls_private_key.auto_gen_key[count.index].private_key_pem}' >\
      ./${var.key_pair_name}.pem
    EOT
  }
  count = var.create_key_pair ? 1 : 0
}
