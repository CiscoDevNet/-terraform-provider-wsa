import json
from os import path
import unittest
from unittest.mock import MagicMock, Mock, patch
from first_boot_config.first_boot_config import BootTimeConfig, requests

class TestBootTimeConfig(unittest.TestCase):

    def setUp(self) -> None:
        self.boot_config = BootTimeConfig("url", "admin", "aXJvbnBvcnQ=")

    def test_enable_smart_licensing(self):
        response_body = "{\"smart_software_licensing_status\": "\
            "\"Enabled\"}"

        with patch('requests.put', MagicMock( \
            return_value=Mock(**{'text': 'Dummy', 'status_code': 200}))), \
            patch('requests.get', MagicMock( \
            return_value=Mock(**{'text': response_body, 'status_code': 200}))):

            self.assertIsNone(self.boot_config._enable_smart_licensing('abc/'))

        with patch('requests.put', MagicMock( \
            return_value=Mock(**{'text': 'Dummy', 'status_code': 300}))), \
            patch('requests.get', MagicMock(\
            return_value=Mock(**{'text': response_body, 'status_code': 200}))):

            self.assertRaisesRegex(Exception, "Smart licence couldn't "\
                "be enabled Dummy", self.boot_config._register_smart_license, \
                'abc/', 'fake_reg')

        response_body = "{\"smart_software_licensing_status\": "\
            "\"ENABLE_REQUESTED\"}"
        with patch('requests.put', MagicMock(\
            return_value=Mock(**{'text': 'Dummy', 'status_code': 200}))), \
            patch('requests.get', MagicMock(\
            return_value=Mock(**{'text': response_body, 'status_code': 200}))),\
            patch('first_boot_config.first_boot_config.MAX_WAIT_FOR_LICENSE_ENABLE', 0):
            self.assertRaisesRegex(Exception, "Even after waiting for 0 "\
                "second, device license couldn't get enabled. So, exiting...", \
                self.boot_config._enable_smart_licensing, "path")



    def test_register_smart_license(self):
        with patch('requests.put', MagicMock(\
            return_value=Mock(**{'text': 'Dummy', 'status_code': 200}))), \
            patch('requests.get', MagicMock(\
            return_value=Mock(**{'text': 'Dummy', 'status_code': 300}))):
            self.assertRaisesRegex(Exception, "Error in reading smart "\
                "license config. Dummy", \
                self.boot_config._register_smart_license, 'abc/', 'fake_reg')

        with patch('requests.put', MagicMock(\
            return_value=Mock(**{'text': 'Dummy', 'status_code': 200}))), \
            patch('requests.get', MagicMock(\
                return_value=Mock(**{'text': '{\"registration_status\": '\
                        '\"Unregistered - Registration Failed\"}', \
                            'status_code': 200}))) as p2:

            self.assertRaisesRegex(Exception, 'Registration request failed.', \
                self.boot_config._register_smart_license, 'abc/', 'fake_reg')

        with patch('requests.put', MagicMock(\
            return_value=Mock(**{'text': 'Dummy', 'status_code': 200}))), \
            patch('requests.get', MagicMock(\
            return_value=Mock(**{'text': "{\"registration_status\": " \
                "\"Registered\"}", 'status_code': 200}))):

            self.assertIsNone(
                self.boot_config._register_smart_license('abc/', 'fake_reg'))

        response_body = "{\"registration_status\": "\
            "\"Product Registration is initiated.\"}"
        with patch('requests.put', MagicMock(\
            return_value=Mock(**{'text': 'Dummy', 'status_code': 200}))), \
            patch('requests.get', MagicMock(\
            return_value=Mock(**{'text': response_body, 'status_code': 200}))),\
            patch('first_boot_config.first_boot_config.MAX_WAIT_FOR_LICENSE_REGISTRATION', 0):
            self.assertRaisesRegex(Exception, "Even after waiting for 0 "\
                "second, device license couldn't "\
                "get registered. So, exiting...", \
                self.boot_config._register_smart_license, "abc/", 'fake_reg')

    def test_load_license(self):
        with patch('first_boot_config.first_boot_config.BootTimeConfig._enable_smart_licensing', \
            MagicMock(return_value=None)), \
            patch('first_boot_config.first_boot_config.BootTimeConfig._register_smart_license', \
            MagicMock(return_value=None)):
            boot_config = BootTimeConfig("url", "admin", "aXJvbnBvcnQ=")
            self.assertIsNone(boot_config.load_license('abc/', "test"))

    def test_perform_ssw(self):
        with patch('requests.put', MagicMock(\
            return_value=Mock(**{'text': 'Dummy', 'status_code': 300}))):
            self.assertRaisesRegex(Exception, 'Error in SSW: Dummy', \
                self.boot_config.perform_ssw, \
                "path", "hostname", "dummy_interface.com", "10.0.1.50", \
                "Q2lzY29AMTIz", "notif_email")

        with patch('requests.put', MagicMock(\
            return_value=Mock(**{'text': 'Dummy', 'status_code': 200}))):
            self.assertIsNone(self.boot_config.perform_ssw("path", "hostname", \
                "dummy_interface.com", "10.0.1.50", \
                "Q2lzY29AMTIz", "notif_email"))


    def test_request_smart_licensing_entitlements(self):
        with patch('requests.put', MagicMock(\
            return_value=Mock(**{'text': 'Dummy', 'status_code': 300}))):
            self.assertRaisesRegex(Exception, \
                "Error in Request for License authorisation: Dummy", \
                self.boot_config.request_smart_licensing_entitlements, "path")


        with patch('requests.put', MagicMock(\
            return_value=Mock(**{'text': 'Dummy', 'status_code': 200}))), \
            patch('requests.get', MagicMock(\
            return_value=Mock(**{'text': 'Dummy', 'status_code': 300}))):
            self.assertRaisesRegex(Exception, \
                "Error in GET request for url url/path: Dummy", \
                self.boot_config.request_smart_licensing_entitlements, "path")

        response_body = "[{\"license_name\": "\
            "\"Secure Web Appliance Web Proxy and DVS Engine\","\
            "\"auth_status\": \"Not In Compliance\"}]"
        with patch('requests.put', MagicMock(\
            return_value=Mock(**{'text': 'Dummy', 'status_code': 200}))), \
            patch('requests.get', MagicMock(\
            return_value=Mock(**{'text': response_body, 'status_code': 200}))):
            self.assertRaisesRegex(Exception,
                "Request for License authorisation failed with following "\
                "reason: {Secure Web Appliance Web Proxy and DVS Engine: "\
                "Not In Compliance}", \
                self.boot_config.request_smart_licensing_entitlements, "path")

        response_body = "[{\"license_name\": "\
            "\"Secure Web Appliance Web Proxy and DVS Engine\","\
            "\"auth_status\": \"In Compliance\"}]"
        with patch('requests.put', MagicMock(\
            return_value=Mock(**{'text': 'Dummy', 'status_code': 200}))), \
            patch('requests.get', MagicMock(\
            return_value=Mock(**{'text': response_body, 'status_code': 200}))):
            self.assertIsNone(
                self.boot_config.request_smart_licensing_entitlements("path"))

        response_body = "[{\"license_name\": "\
            "\"Secure Web Appliance Web Proxy and DVS Engine\","\
            "\"auth_status\": \"Request in progress\"}]"
        with patch('requests.put', MagicMock(\
            return_value=Mock(**{'text': 'Dummy', 'status_code': 200}))), \
            patch('requests.get', MagicMock(\
            return_value=Mock(**{'text': response_body, 'status_code': 200}))),\
            patch('first_boot_config.first_boot_config.MAX_WAIT_FOR_LICENSE_AUTHORIZATION', 0):
            self.assertRaisesRegex(Exception, "Even after waiting for 0 "\
                "seconds, License Authorization Status is still in progress. "\
                "Exiting...", \
                self.boot_config.request_smart_licensing_entitlements, "path")


    def test_release_smart_licensing_entitlements(self):
        with patch('requests.put', MagicMock(\
            return_value=Mock(**{'text': 'Dummy', 'status_code': 200}))), \
            patch('requests.get', MagicMock(\
            return_value=Mock(**{'text': 'Dummy', 'status_code': 300}))):
            self.assertRaisesRegex(Exception,
                "GET request for License authorisation failed", \
                self.boot_config.release_smart_licensing_entitlements, "path")

        with patch('requests.put', MagicMock(\
            return_value=Mock(**{'text': 'Dummy', 'status_code': 300}))), \
            patch('requests.get', MagicMock(\
            return_value=Mock(**{'text': "[]", 'status_code': 200}))):
            self.assertRaisesRegex(Exception,
                "Release of License authorisation failed", \
                self.boot_config.release_smart_licensing_entitlements, "path")

        with patch('requests.put', MagicMock(\
            return_value=Mock(**{'text': 'Dummy', 'status_code': 200}))), \
            patch('requests.get', MagicMock(\
            return_value=Mock(**{'text': "[]", 'status_code': 200}))):
            self.assertIsNone(
                self.boot_config.release_smart_licensing_entitlements("path"))

if __name__ == "__main__":
    unittest.main()




