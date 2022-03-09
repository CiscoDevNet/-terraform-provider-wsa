# Python module first_boot_config

## Usage

It takes various command line arguments:

usage: first_boot_config.py [-h] -hn HOSTNAME [-dh DATA_INTERFACE_HOSTNAME] [-di DATA_INTERFACE_IP] [-dm DATA_INTERFACE_NETMASK]
                            [-dg DATA_INTERFACE_GATEWAY_IP] [-tp TRAILBLAZER_PORT] [-us USERNAME] [-pw PASSWORD] -st SMART_LICENSE_TOKEN
                            [-sp SSW_PASSWORD] [-ne NOTIF_EMAIL] [-rl] [-ll {CRITICAL,ERROR,WARNING,INFO,DEBUG}]

###  Arguments:

| Short arguments | Long arguments | Description |
| --------------- | -------------- | ----------- |
| -h | --help | show this help message and exit |
| -hn HOSTNAME | --hostname HOSTNAME | public hostname |
| -dh DATA_INTERFACE_HOSTNAME | --data_interface_hostname DATA_INTERFACE_HOSTNAME | data interface hostname |
| -di DATA_INTERFACE_IP | --data_interface_ip DATA_INTERFACE_IP | data interface ip |
| -dm DATA_INTERFACE_NETMASK | --data_interface_netmask DATA_INTERFACE_NETMASK | data interface netmask, eg: 16, 24 etc. |
| -dg DATA_INTERFACE_GATEWAY_IP | --data_interface_gateway_ip DATA_INTERFACE_GATEWAY_IP | data interface gateway ip |
| -tp TRAILBLAZER_PORT | --trailblazer_port TRAILBLAZER_PORT | Trailblazer port |
| -us USERNAME | --username USERNAME | username (ex: admin) |
| -pw PASSWORD | --password PASSWORD | Password of device, you want to set (in base64 format. ex: aXJvbnBvcnQ=) |
| -st SMART_LICENSE_TOKEN | --smart_license_token SMART_LICENSE_TOKEN | Smart License Registration Token. |
| -sp SSW_PASSWORD | --ssw_password SSW_PASSWORD | SSW password |
| -ne NOTIF_EMAIL | --notif_email NOTIF_EMAIL | Notification email |
| -rl | --release_license |Use this option without any value to release licences. |
| -ll {CRITICAL,ERROR,WARNING,INFO,DEBUG} | --log_level {CRITICAL,ERROR,WARNING,INFO,DEBUG} | Log level. Possible values are [CRITICAL, ERROR, WARNING, INFO, DEBUG] |



## Dependencies

Before running this script, make sure you fulfil following dependencies.

1. python3 (any version)
2. "requests" module of python should be installed




