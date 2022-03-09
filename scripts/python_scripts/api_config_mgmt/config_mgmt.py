import json
import traceback
import base64
import logging
import requests
from requests.auth import HTTPBasicAuth
import config_api_info as config
import device_info as device
from abc import ABC, abstractmethod

logging.basicConfig(filename='Configuration.log', \
    filemode='a', level=logging.INFO, \
    format='%(asctime)s | %(levelname)s | %(message)s', \
    datefmt='%H:%M:%S')
logger = logging.getLogger('Configuration API')
logger.info('====================================================')

requests.urllib3.disable_warnings()

class APIMethods:

    def GET(self):
        logger.info("GET : " + self.baseURL + self.url)
        response = requests.get(self.baseURL + self.url, verify=False,\
                timeout=self.timeout, auth=self.auth)
        return self.response_status_handler(response)

    def POST(self):
        logger.info("POST : " + self.baseURL + self.url)
        response = requests.post(self.baseURL + self.url, verify=False,\
                timeout=self.timeout, json=self.json_body, auth=self.auth)
        return self.response_status_handler(response)

    def PUT(self):
        logger.info("PUT : " + self.baseURL + self.url)
        response = requests.put(self.baseURL + self.url, verify=False,\
                timeout=self.timeout, json=self.json_body, auth=self.auth)
        return self.response_status_handler(response)

    def DELETE(self):
        logger.info("DELETE : " + self.baseURL + self.url)
        response = requests.delete(self.baseURL + self.url, verify=False,\
                timeout=self.timeout, auth=self.auth)
        return self.response_status_handler(response)

    def PUT_MULTIPART(self):
        logger.info("PUT MULTIPART : " + self.baseURL + self.url)
        files = []
        if self.files:
            for item in self.files:
                files.append((item[0], (item[1][item[1].rfind("/")+1:], \
                    open(item[1], 'rb'), 'application/octet-stream')))
        multipart_data = {}
        for item in self.json_body:
            if type(self.json_body[item]).__name__ == 'dict':
                multipart_data[item] = json.dumps(self.json_body[item])
            else:
                multipart_data[item] = self.json_body[item]
        if not files:
            files = [(None, None)]

        response = requests.put(self.baseURL + self.url, verify=False,\
                timeout=self.timeout, files=files, data=multipart_data,\
                auth=self.auth)
        return self.response_status_handler(response)


    def POST_MULTIPART(self):
        logger.info("POST MULTIPART : " + self.baseURL + self.url)
        files = []
        if self.files:
            for item in self.files:
                files.append((item[0], (item[1][item[1].rfind("/")+1:], \
                    open(item[1], 'rb'), 'application/octet-stream')))
        multipart_data = {}
        for item in self.json_body:
            if type(self.json_body[item]).__name__ == 'dict':
                multipart_data[item] = json.dumps(self.json_body[item])
            else:
                multipart_data[item] = self.json_body[item]

        if not files:
            files = [(None, None)]

        response = requests.post(self.baseURL + self.url, verify=False,\
                timeout=self.timeout, files=files, data=multipart_data,\
                auth=self.auth)
        return self.response_status_handler(response)

    def __init__(self, api) -> None:
        self.timeout = api["timeout"]
        self.username = api["username"]
        self.password = base64.standard_b64decode(api["password"]).decode()
        self.auth = HTTPBasicAuth(
            username=self.username, password=self.password)
        self.url = api[config.URL]
        self.method = api[config.METHOD] if config.METHOD in api else None
        self.data_type = api[config.DATA_TYPE] if config.DATA_TYPE in api \
            else None
        self.json_body = api[config.JSON_BODY] if config.JSON_BODY in api \
            else None
        self.name = api[config.DISPLAY_NAME]
        self.baseURL = api["baseURL"]
        self.files = None
        if "files" in api:
            self.files = api["files"]
        self.result_ignore = api["result_ignore"] if "result_ignore" in api \
            else False


    def api_call(self):

        if self.method == config.DELETE:
            (ret_val, response) = self.DELETE()
        elif self.method == config.GET:
            (ret_val, response) = self.GET()
        elif self.data_type == config.MULTI_FORM_DATA:
            (ret_val, response) = self.PUT_MULTIPART()
            if not ret_val and not self.method:
                (ret_val, response) = self.POST_MULTIPART()
        elif not self.method or self.method == config.PUT:
            (ret_val, response) = self.PUT()
            if not ret_val and not self.method:
                (ret_val, response) = self.POST()
        else:
            raise RuntimeError('Method/Data_type not supported : ' \
                + self.baseURL + self.url)

        return (ret_val, response)

    @abstractmethod
    def response_status_handler(self, response):
        pass


class APIMethodsV3(APIMethods):

    def response_status_handler(self, response):
        return (response.status_code in [204, 200, 201], response)


class APIMethodsV2(APIMethods):

    def response_status_handler(self, response):
        if response.json() and "res_code" in response.json():
            return (response.json()["res_code"] in [200, 201], response)
        else:
            return (False, response)


def execute_all_API(wsa):

    baseURL = "https://" + wsa + ":" \
            + str(device.WSA_PORT) + "/wsa/api/"

    for api in config.API:
        api["baseURL"] = baseURL
        api["username"] = device.WSA_USERNAME
        api["password"] = device.WSA_PASSWORD
        api["timeout"] = config.API_TIMEOUT
        if config.IGNORE_RESULT not in api:
            api[config.IGNORE_RESULT] = False

        if config.JSON_FILE in api:
            api[config.JSON_FILE] = config.PAYLOAD_DIR + api[config.JSON_FILE]
            try:
                json_file = open(api[config.JSON_FILE], "r")
                json_body = json.load(json_file)
                if "@files_upload" in json_body:
                    files = []
                    for item in json_body["@files_upload"]:
                        files.append((item[0], item[1]))
                    api["files"] = files
                    del json_body["@files_upload"]
                api[config.JSON_BODY] = json_body
            except Exception:
                raise RuntimeError('JSON Error : Unable to process ' \
                    + api[config.JSON_FILE])

        if api[config.URL].startswith("v2.0"):
            (ret_val, response) = APIMethodsV2(api).api_call()
        elif api[config.URL].startswith("v3.0"):
            (ret_val, response) = APIMethodsV3(api).api_call()
        else:
            raise RuntimeError('Not a valid URL : ' \
                + api["baseURL"] + api[config.URL])


        if api[config.IGNORE_RESULT] and not ret_val:
            logger.info("Ignoring : " + api["baseURL"] + api[config.URL] \
                + " " + str(response.content))
        elif not ret_val:
            raise RuntimeError('API Error : ' \
                + api["baseURL"] + api[config.URL] + " "\
                + str(response.content))
        else:
            logger.info("SUCCESS : " + api["baseURL"] + api[config.URL])


def download_config(device_download):
    api = {
        config.DISPLAY_NAME: 'Download Configuration File',
        config.URL         : 'v3.0/system_admin/configuration_file?\
passphrase_action=encrypt,filename=' + config.CONFIG_FILENAME,
        config.METHOD      : config.GET,
        "baseURL"          : "https://" + device_download + ":" + \
            str(device.WSA_PORT) + "/wsa/api/",
        "username"         : device.WSA_USERNAME,
        "password"         : device.WSA_PASSWORD,
        "timeout"          : config.API_TIMEOUT
    }
    (ret_val, response) = APIMethodsV3(api).api_call()
    if ret_val:
        downloaded_file = open(config.CONFIG_FILENAME, "wb")
        downloaded_file.write(response.content)
        downloaded_file.close()
        logger.info("SUCCESS : " + api["baseURL"] + api[config.URL])
    else:
        raise RuntimeError('Download Configuration file Failed : ' \
                + api["baseURL"] + api[config.URL] + " " \
                + str(response.content))


def upload_config(devices_upload):
    api = {
        config.DISPLAY_NAME: 'Upload Configuration File',
        config.URL         : 'v3.0/system_admin/configuration_file',
        config.DATA_TYPE   : config.MULTI_FORM_DATA,
        config.METHOD      : config.PUT,
        config.JSON_BODY   :{
            'source' : 'local',
            'action' : 'load',
        },
        "files"            : [('uploaded_file', config.CONFIG_FILENAME)],
        "username"         : device.WSA_USERNAME,
        "password"         : device.WSA_PASSWORD,
        "timeout"          : config.API_TIMEOUT
    }
    for device_upload in devices_upload:
        api["baseURL"] = "https://" + device_upload + ":" + \
            str(device.WSA_PORT) + "/wsa/api/"
        (ret_val, response) = APIMethodsV3(api).api_call()
        if not ret_val:
            raise RuntimeError('Upload Configuration file Failed : ' \
                    + api["baseURL"] + api[config.URL] + " " \
                    + str(response.content))
        else:
            logger.info("SUCCESS : " + api["baseURL"] + api[config.URL])

if __name__ == "__main__":

    try:
        if len(device.ALL_WSA) == 0:
            raise RuntimeError('No Device to configure')
        devices_upload = []
        if config.CONFIGURATION_TYPE == 'ZERODAY_CONFIG':
            execute_all_API(device.ALL_WSA[0])
            download_config(device.ALL_WSA[0])
            devices_upload = device.ALL_WSA[1:]
        elif config.CONFIGURATION_TYPE == 'UPDATE_CONFIG':
            for wsa in device.ALL_WSA:
                execute_all_API(wsa)
        elif config.CONFIGURATION_TYPE == 'UPLOAD_CONFIG':
            devices_upload = device.ALL_WSA

        upload_config(devices_upload)

    except Exception as ex:
        logger.error(ex)
        traceback.print_exc()
