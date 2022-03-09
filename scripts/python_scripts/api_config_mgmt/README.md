## WSA Configuration by RestAPI

Configuration Management module can configure multiple WSA by RestAPI calls with the provided APIs and payloads.

1. Configuration Management module will be automatically executed as the part of Terraform instance creation by default
2. User can Execute Configuration Management module manually whenever the WSA configuration needs to updated.

Information provided in device_info.py, config_api_info.py and payload / files directory are sample configuration information.
It is Admin's responsibility to modify the information in the above mentioned files and directories suitable to their WSA configuration needs 

# Dependencies
1. python3 
2. "requests" module of python should be installed

# Usage
$ python config_mgmt.py

# device_info.py
This file will get Automatically updated by Terraform Automation script.
To execute Configuration management module separately, Admin needs to manually edit this file based on their requirement.

    ALL_WSA         - List of WSA devices with same version. Provided configuration is updated in all the WSA device mentioned ALL_WSA
    WSA_USERNAME    - Username to access the devices
    WSA_PASSWORD    - Password to access the devices (Encoded Base64)
    WSA_PORT        - RestAPI port

# config_api_info.py
Edit/Update this configuration file before initiating Terraform instance creation script or before manually executing the Configuration Management Script.

    API_TIMEOUT         - Timeout for each API request
    PAYLOAD_DIR         - API's payload file directory location
    CONFIG_FILENAME     - WSA XML configuration file
    CONFIGURATION_TYPE  - Type how WSA is configured
        # "ZERODAY_CONFIG" - Configure first WSA mentioned (device_info.ALL_WSA) by executing all APIs, and then downloads the Config file and Upload to all other WSAs in device_info.ALL_WSA)
        # "UPDATE_CONFIG"  - Configure all WSA (device_info.ALL_WSA), by executing all the APIs in all the WSAs
        # "UPLOAD_CONFIG"  - Uploads provided WSA XML configuration file (CONFIG_FILENAME) to all the WSAs
        
    API     - List of all API to be configured in the WSA
        DISPLAY_NAME    - String information about the API
        URL             - API URL
        JSON_FILE       - API's body - Payload json file
        DATA_TYPE       - (Optional) MULTI_FORM_DATA - If the payload has to be transferred as multi-part formdata
        IGNORE_RESULT   - (Optional) True - In this case Script execution will not cease, even if there is error response for the API
        METHOD          - (Optional) URL METHOD 
            Optional    - if not provided , considered as PUT and then POST only if PUT has error response
            PUT         - API is called with PUT method
            DELETE      - API is called with DELETE method
        
        
# Payload JSON files
    
    It should be a valid json file.
    Multi-Part FormData, params should also be mentioned as json.
    In case there are files to be uploaded by Multi-Part FormData, use "@files_upload" key to assign all the files as list(name, file).
    eg:- 
    {
    "@files_upload":[
        [
            "reputation_server_cert",
            "payload/files/Baltimore CyberTrust Root.cert.pem"
        ],
        [
            "reputation_server_ca_cert",
            "payload/files/server_ca_cert.pem"
        ]
    ]
    }

