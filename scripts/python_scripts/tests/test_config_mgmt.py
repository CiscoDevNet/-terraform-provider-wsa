import json
from os import path
import unittest
from unittest.mock import MagicMock, Mock, patch
from api_config_mgmt.config_mgmt import APIMethodsV3, APIMethodsV2, requests, execute_all_API, config

    
class TestConfigurationManagement(unittest.TestCase):

    def setUp(self) -> None:
        self.wsa = "1.2.3.4"
        self.apiv3 = []
        self.apiv3_multipart = []
        self.apiv2 = []
        self.apiv2_multipart = []

    def initialize(self):
        self.apiv3 = [
            {
                config.DISPLAY_NAME: 'AUTH Realm- TestRealm1',
                config.URL         : 'v3.0/network/auth_realms',
                config.JSON_FILE   : 'Auth_Realm-TestRealm1.json',
            }]
        self.apiv3_multipart = [
            {
                config.DISPLAY_NAME: 'PAC Files - Upload',
                config.URL         : 'v3.0/security_services/pac_file',
                config.JSON_FILE   : 'PAC_Files_upload.json',
                config.DATA_TYPE   : config.MULTI_FORM_DATA,
            }]
        self.apiv2 = [
            {
                config.DISPLAY_NAME: 'URL Categories',
                config.URL         : 'v2.0/configure/web_security/url_categories',
                config.JSON_FILE   : 'URL_categories.json',
            }]

    def test_put(self):
        self.initialize()
        config.API = self.apiv3
        config.API[0][config.METHOD] = config.PUT
        with patch('requests.put', MagicMock( \
            return_value=Mock(**{'text': {}, 'status_code': 204}))):
            self.assertIsNone(execute_all_API(self.wsa))

        self.initialize()
        config.API = self.apiv3
        config.API[0][config.METHOD] = config.PUT
        with patch('requests.put', MagicMock( \
            return_value=Mock(**{'text': {'error' : ' Unable to PUT'}, 'status_code': 404}))):
            with self.assertRaises(Exception):
                execute_all_API(self.wsa)


    def test_put_post(self):
        self.initialize()
        config.API = self.apiv3
        with patch('requests.put', MagicMock( \
            return_value=Mock(**{'text': {'error' : ' Unable to PUT'}, 'status_code': 404}))), \
            patch('requests.post', MagicMock( \
            return_value=Mock(**{'text': {}, 'status_code': 204}))):
            self.assertIsNone(execute_all_API(self.wsa))

        self.initialize()
        config.API = self.apiv3
        with patch('requests.put', MagicMock( \
            return_value=Mock(**{'text': {'error' : ' Unable to PUT'}, 'status_code': 404}))), \
            patch('requests.post', MagicMock( \
            return_value=Mock(**{'text': {'error' : ' Unable to POST'}, 'status_code': 404}))):
            with self.assertRaises(Exception):
                execute_all_API(self.wsa)


    def test_multipart_put(self):
        self.initialize()
        config.API = self.apiv3_multipart
        config.API[0][config.METHOD] = config.PUT
        with patch('requests.put', MagicMock( \
            return_value=Mock(**{'text': {}, 'status_code': 204}))):
            self.assertIsNone(execute_all_API(self.wsa))

        self.initialize()
        config.API = self.apiv3_multipart
        config.API[0][config.METHOD] = config.PUT
        with patch('requests.put', MagicMock( \
            return_value=Mock(**{'text': {'error' : ' Unable to PUT'}, 'status_code': 404}))):
            with self.assertRaises(Exception):
                execute_all_API(self.wsa)


    def test_multipart_put_post(self):
        self.initialize()
        config.API = self.apiv3_multipart
        with patch('requests.put', MagicMock( \
            return_value=Mock(**{'text': {'error' : ' Unable to PUT'}, 'status_code': 404}))), \
            patch('requests.post', MagicMock( \
            return_value=Mock(**{'text': {}, 'status_code': 204}))):
            self.assertIsNone(execute_all_API(self.wsa))

        self.initialize()
        config.API = self.apiv3_multipart
        with patch('requests.put', MagicMock( \
            return_value=Mock(**{'text': {'error' : ' Unable to PUT'}, 'status_code': 404}))), \
            patch('requests.post', MagicMock( \
            return_value=Mock(**{'text': {'error' : ' Unable to POST'}, 'status_code': 404}))):
            with self.assertRaises(Exception):
                execute_all_API(self.wsa)


    def test_v2_put_post(self):
        class response:
            def json(self):
                return {"res_code": 200}
        class fail_response:
            def json(self):
                return {"res_code": 400}

        self.initialize()
        config.API = self.apiv2
        with patch('requests.put', MagicMock( \
            return_value=fail_response())), \
            patch('requests.post', MagicMock( \
            return_value=response())):
            self.assertIsNone(execute_all_API(self.wsa))

        self.initialize()
        config.API = self.apiv2
        with patch('requests.put', MagicMock( \
            return_value=fail_response())), \
            patch('requests.post', MagicMock( \
            return_value=fail_response())):
            with self.assertRaises(Exception):
                execute_all_API(self.wsa)

if __name__ == "__main__":
    unittest.main()



