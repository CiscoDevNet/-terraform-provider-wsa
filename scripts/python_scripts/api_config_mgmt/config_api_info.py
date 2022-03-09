
DISPLAY_NAME    = "DISPLAY_NAME"
URL             = "URL"
METHOD          = "METHOD"
JSON_FILE       = "JSON_FILE"
JSON_BODY       = "json_body"
DELETE          = "delete"
MULTI_FORM_DATA = "multipart/form-data"
GET             = 'get'
PUT             = 'put'
IGNORE_RESULT   = 'ignore_on_failure'
DATA_TYPE       = 'data_type'

####################################################################################################

API_TIMEOUT = 90        # in seconds
PAYLOAD_DIR = "payload/"
CONFIG_FILENAME = "config_1.xml"
# For uploading existing configuration XML file, Assign configuration XML file's full name to CONFIG_FILENAME
# and make CONFIGURATION_TYPE as UPLOAD_CONFIG

CONFIGURATION_TYPE = "ZERODAY_CONFIG"
# "ZERODAY_CONFIG" - Configure API call to one WSA, Download Config file and Upload to all other WSAs
# "UPDATE_CONFIG" - Configure API call to all WSAs
# "UPLOAD_CONFIG" - Upload provided congfiguration file to all the WSAs

API = [

    {
        DISPLAY_NAME: 'AUTH Realm- TestRealm1',
        URL         : 'v3.0/network/auth_realms',
        JSON_FILE   : 'Auth_Realm-TestRealm1.json',
        IGNORE_RESULT : True
    },
    {
        DISPLAY_NAME: 'HTTPS Proxy - Enable',
        URL         : 'v2.0/configure/security_services/proxy/https',
        JSON_FILE   : 'HTTPS_Proxy_Enable.json',
        METHOD      : PUT,
        DATA_TYPE   : MULTI_FORM_DATA,
    },
    {
        DISPLAY_NAME: 'ID Profile - ID1',
        URL         : 'v3.0/web_security/identification_profiles',
        JSON_FILE   : 'ID_Profile-ID1.json'
    },
    {
        DISPLAY_NAME: 'ID Profile - ID2',
        URL         : 'v3.0/web_security/identification_profiles',
        JSON_FILE   : 'ID_Profile-ID2.json'
    },
    {
        DISPLAY_NAME: 'AP - TestAP2',
        URL         : 'v3.0/web_security/access_policies',
        JSON_FILE   : 'Accessp_Policy-TestAP2.json'
    },
    {
        DISPLAY_NAME: 'RP - RouPolicy2',
        URL         : 'v3.0/web_security/routing_policies',
        JSON_FILE   : 'Routing_Policy-RouPolicy2.json'
    },
    {
        DISPLAY_NAME: 'DP - DecryptPolicy2',
        URL         : 'v3.0/web_security/decryption_policies',
        JSON_FILE   : 'Decrytion_Policy-DecryptPolicy2.json'
    },
    {
        DISPLAY_NAME: 'PAC Files - Upload',
        URL         : 'v3.0/security_services/pac_file',
        JSON_FILE   : 'PAC_Files_upload.json',
        DATA_TYPE   : MULTI_FORM_DATA,
        IGNORE_RESULT : True
    },
    {
        DISPLAY_NAME: 'URL Categories',
        URL         : 'v2.0/configure/web_security/url_categories',
        JSON_FILE   : 'URL_categories.json'
    },
    {
        DISPLAY_NAME: 'Umbrella Seamless ID',
        URL         : 'v3.0/web_security/umbrella_seamless_id',
        JSON_FILE   : 'Umbrella_seamless_ID.json',
        # IGNORE_RESULT : True
    },
    {
        DISPLAY_NAME: 'DNS',
        URL         : 'v2.0/configure/network/dns',
        JSON_FILE   : 'DNS.json',
        # IGNORE_RESULT : True
    },
    {
        DISPLAY_NAME: 'IP Spoofing Profiles',
        URL         : 'v3.0/web_security/ip_spoofing_profiles',
        JSON_FILE   : 'IP_Spoofing_profiles.json',
    },
    {
        DISPLAY_NAME: 'Appliance Certificate',
        URL         : 'v2.0/configure/network/certificates/appliance',
        JSON_FILE   : 'Appliance_cert.json',
    },
    {
        DISPLAY_NAME: 'Upstream Proxy',
        URL         : 'v2.0/configure/network/upstream_proxy',
        JSON_FILE   : 'Upstream_proxy.json',
        IGNORE_RESULT : True
    },
    {
        DISPLAY_NAME: 'Bypass Proxy',
        URL         : 'v2.0/configure/web_security/bypass_proxy',
        JSON_FILE   : 'Bypass_Proxy.json',
    },
    {
        DISPLAY_NAME: 'Global Auth Settings',
        URL         : 'v3.0/network/global_auth_setting',
        JSON_FILE   : 'Global_Auth_settings.json',
        METHOD      : PUT,
        DATA_TYPE   : MULTI_FORM_DATA,
    },
    {   # Need proper keys
        DISPLAY_NAME: 'Feature keys',
        URL         : 'v2.0/configure/system/feature_key',
        JSON_FILE   : 'Feature_keys.json',
        IGNORE_RESULT : True
    },
    {
        DISPLAY_NAME: 'Anti-Malware and Reputation',
        URL         : 'v3.0/security_services/anti_malware_and_reputation',
        JSON_FILE   : 'AntiMalware_and_Reputation.json',
        METHOD      : PUT,
        DATA_TYPE   : MULTI_FORM_DATA,
        IGNORE_RESULT : True
    },
    {
        DISPLAY_NAME: 'Certificate management - Trusted Certificate',
        URL         : 'v2.0/configure/network/certificates/trusted',
        JSON_FILE   : 'Trust_certificate.json',
        METHOD      : PUT,
    },
    {
        DISPLAY_NAME: 'Certificate management - Upload Custom Trusted Cert',
        URL         : 'v2.0/configure/network/certificates/custom_trusted',
        JSON_FILE   : 'Upload_Custom_Trust_cert.json',
        # METHOD      : PUT,
        DATA_TYPE   : MULTI_FORM_DATA,
        IGNORE_RESULT : True
    },
    {
        DISPLAY_NAME: 'Certificate management - Upload Auth Cert',
        URL         : 'v2.0/configure/network/certificates/auth',
        JSON_FILE   : 'Upload_Auth_cert.json',
        # METHOD      : PUT,
        DATA_TYPE   : MULTI_FORM_DATA,
        IGNORE_RESULT : True
    },

]
