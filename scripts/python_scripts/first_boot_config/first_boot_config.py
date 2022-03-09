""" This script can be used for first time provisioning of a WSA device. """
# pylint: disable=C0209

import os
import http
import json
from time import sleep, time
import base64
import logging
from http import client as http_client
import requests
from requests.auth import HTTPBasicAuth

logging.basicConfig(filename='first_boot_config.log', \
    filemode='a', level=logging.INFO, \
    format='%(asctime)s | %(levelname)s | %(message)s', \
    datefmt='%H:%M:%S')
logger = logging.getLogger('first_boot_config')
logger.info('====================================================')

# It will supress certificate validation,
# while communicating with WSA instances.
requests.urllib3.disable_warnings()

RETRY_INTERVAL = 5
LOAD_LICENSE_PATH = "wsa/api/v3.0/system_admin/smart_software_licensing_status"
LOAD_CONFIG_PATH = "wsa/api/v3.0/system_admin/configuration_file"
PERFORM_SSW_PATH = "wsa/api/v3.0/system_admin/system_setup_wizard"
LICENSE_ENTITLEMENT_PATH = "wsa/api/v3.0/system_admin/sl_licenses"

MAX_WAIT_FOR_DEVICE_UP = 1800  # 30 minutes
MAX_WAIT_FOR_LICENSE_REGISTRATION = 300 # 5 minutes
MAX_WAIT_FOR_LICENSE_AUTHORIZATION = 600 # 10 minutes
MAX_WAIT_FOR_LICENSE_ENABLE = 120

class BootTimeConfig:
    """ It provides utility functions to perform first time WSA configuration"""

    def __init__(self, url, username, password) -> None:
        self.url = url
        self.username = username
        self.password = base64.standard_b64decode(password).decode()
        self.auth = HTTPBasicAuth(
            username=self.username, password=self.password)

    def _enable_smart_licensing(self, url):
        """ It enables smart licensing. """
        request_body = {'smart_license_status': 'enable'}
        response = requests.put(
            url, verify=False, json=request_body, auth=self.auth)
        if response.status_code >= http.HTTPStatus.MULTIPLE_CHOICES:
            raise Exception(f"Smart licence couldn't be enabled {response.text}")
        requested = True
        start_time = time()
        while requested:
            response = requests.get(url, verify=False, auth=self.auth)
            if response.status_code >= http.HTTPStatus.MULTIPLE_CHOICES:
                raise Exception(f"Smart licence GET failed: {response.text}")
            response_obj = json.loads(response.text)
            if response_obj.get('smart_software_licensing_status') != \
                'ENABLE_REQUESTED':
                break
            if time() - start_time > MAX_WAIT_FOR_LICENSE_ENABLE:
                raise Exception(f"Even after waiting for "\
                    f"{MAX_WAIT_FOR_LICENSE_ENABLE} second, device "\
                    f"license couldn't get enabled. So, exiting...")
            logger.info (f"Smart license is being enabled, we will check after "
                f"{RETRY_INTERVAL} seconds...")
            sleep(RETRY_INTERVAL)

        logger.info ("Smart license enabled")

    def _register_smart_license(self, url, smart_license_token):
        """ It registers smart licensing by given token. """
        request_body = {
            "action": "register", "registration_token": smart_license_token}
        response = requests.put(
            url, verify=False, json=request_body, auth=self.auth)
        if response.status_code >= http.HTTPStatus.MULTIPLE_CHOICES:
            raise Exception(f"Smart licence couldn't be enabled {response.text}")
        registering = True
        registering_string = "Product Registration is initiated."
        registeration_failed_str = "Unregistered - Registration Failed"
        logger.info ("Registering smart license...")
        start_time = time()
        while registering:
            response = requests.get(url, verify=False, auth=self.auth)
            if response.status_code >= http.HTTPStatus.MULTIPLE_CHOICES:
                raise Exception(
                    f"Error in reading smart license config. {response.text}")
            response_body = json.loads(response.text)
            if response_body.get('registration_status', '') != \
                registering_string:
                if response_body.get('registration_status', '') == \
                    registeration_failed_str:
                    raise Exception("Registration request failed.")
                break
            if time() - start_time > MAX_WAIT_FOR_LICENSE_REGISTRATION:
                raise Exception(f"Even after waiting for "\
                    f"{MAX_WAIT_FOR_LICENSE_REGISTRATION} second, device "\
                    f"license couldn't get registered. So, exiting...")
            sleep(RETRY_INTERVAL)
            logger.info ("Still registering...")
        logger.info ("Smart license registered successfully.")

    def load_license(self, path, smart_license_token) -> bool:
        """ It loads smart license. """
        url = self.url + "/" + path
        self._enable_smart_licensing(url)
        self._register_smart_license(url, smart_license_token)
        logger.info ("License loaded successfully")

    def load_config(self, path, filename, filepath):
        """ It loads config file to WSA. """
        url = self.url + "/" + path
        files = {
            'uploaded_file': (filename, open(filepath, 'rb')),
        }
        data= {
            'action': 'load',
            'source': 'local',
        }
        logger.info ("uploading file")
        response = requests.put(
            url, files=files, data=data, auth=self.auth, verify=False)
        logger.info (response.text)
        if response.status_code >= http.HTTPStatus.MULTIPLE_CHOICES:
            raise Exception(f"Error in config upload {response.text}")
        logger.info ('Config loaded successfully.')

    def perform_ssw(self, path, hostname, data_interface_hostname, \
            data_interface_ip, data_interface_netmask, \
            data_interface_gateway_ip, ssw_password, notif_email):
        """ It perform SSW on WSA. """
        url = self.url + "/" + path
        request_body = {
            "network_admin": {
                "passphrase": ssw_password,
                "mail_to_addrs": [notif_email]
            },
            "cisco_license_agreement": "accept",
            "system_settings": {
                "hostname": hostname
            },
            "network_interface": {
                "m1": {
                    "hostname": hostname,
                    "management_only": "yes" if data_interface_hostname \
                        else "no"
                }
            }
        }
        if data_interface_hostname:
            request_body['network_interface']['p1'] = {
                "hostname": data_interface_hostname,
                "ipv4_address_netmask": \
                    f'{data_interface_ip}/{data_interface_netmask}'
            }
            request_body['network_routes'] = {
                "data" : {"default_gateway": data_interface_gateway_ip}
            }

        response = requests.put(
                url, verify=False, json=request_body, auth=self.auth)
        logger.info (response.text)
        if response.status_code >= http.HTTPStatus.MULTIPLE_CHOICES:
            raise Exception(f"Error in SSW: {response.text}")
        self.password = base64.standard_b64decode(ssw_password).decode()
        self.auth = HTTPBasicAuth(username=self.username, password=self.password)
        logger.info ("SSW successfully performed")

    def request_smart_licensing_entitlements(self, path: str) -> None:
        """ It requests multiple 'License authorisations'. """
        def request() -> None:
            """ Perorm PUT request and send License authorisation request. """
            request_body = {
                "request": entitlements
            }
            response = requests.put(
                    url, verify=False, json=request_body, auth=self.auth)
            if response.status_code >= http.HTTPStatus.MULTIPLE_CHOICES:
                raise Exception(
                    f"Error in Request for License authorisation: {response.text}")

        def check_state(entitlements) -> bool:
            """
            Perform a lookup whether License authorisation
            request got fulfilled or not.
            """
            response = requests.get(url, verify=False, auth=self.auth)
            if response.status_code >= http.HTTPStatus.MULTIPLE_CHOICES:
                raise Exception(
                    f"Error in GET request for url {url}: {response.text}")
            response_list = json.loads(response.text)
            for entity in response_list:
                if entity['license_name'] not in entitlements:
                    continue
                if entity.get('auth_status', '') == 'Request in progress':
                    return False
                if entity.get('auth_status', '') != 'In Compliance':
                    raise Exception("Request for License authorisation "\
                        "failed with following reason: {%s: %s}" \
                            % (entity['license_name'], \
                            entity.get('auth_status', ''), ))
            return True
        entitlements = [
            "Secure Web Appliance Cisco Web Usage Controls",
            "Secure Web Appliance Anti-Virus Webroot",
            "Secure Web Appliance L4 Traffic Monitor",
            "Secure Web Appliance Cisco AnyConnect SM for AnyConnect",
            "Secure Web Appliance Malware Analytics Reputation",
            "Secure Web Appliance Anti-Virus Sophos",
            "Secure Web Appliance Web Reputation Filters",
            "Secure Web Appliance Malware Analytics",
            "Secure Web Appliance Anti-Virus McAfee",
            "Secure Web Appliance Web Proxy and DVS Engine",
            "Secure Web Appliance HTTPs Decryption"
        ]
        url = self.url + "/" + path
        request()
        start_time = time()
        while not check_state(entitlements):
            if time() - start_time > MAX_WAIT_FOR_LICENSE_AUTHORIZATION:
                raise Exception("Even after waiting for %d seconds, "\
                    "License Authorization Status "\
                    "is still in progress. Exiting..." % \
                    MAX_WAIT_FOR_LICENSE_AUTHORIZATION)
            logger.info ("License Authorization Status being enabled, Will recheck "\
                "after %d seconds " % RETRY_INTERVAL)
            sleep(RETRY_INTERVAL)
        logger.info ("These entitlements enabled successfully: %s" % entitlements)

    def release_smart_licensing_entitlements(self, path):
        """ It releases the authorized licenses. """
        def get_enabled_enititlements():
            """ Sends a GET request and gets enabled license list. """
            entitlements = []
            # Perform GET
            response = requests.get(url, verify=False, auth=self.auth)
            if response.status_code >= http.HTTPStatus.MULTIPLE_CHOICES:
                raise Exception ("GET request for License authorisation failed")
            response_list = json.loads(response.text)
            for entity in response_list:
                if entity.get('auth_status', '') == 'In Compliance':
                    entitlements.append(entity['license_name'])
            return entitlements

        def release_enabled_enititlements(entitlements):
            """
            It should get called before destruction (on cloud)
            or reinst of device.
            """
            # Release resources
            request_body = {
                "release": entitlements
            }
            response = requests.put(
                    url, verify=False, json=request_body, auth=self.auth)
            if response.status_code >= http.HTTPStatus.MULTIPLE_CHOICES:
                raise Exception ("Release of License authorisation failed")
        url = self.url + "/" + path
        entitlements = get_enabled_enititlements()
        release_enabled_enititlements(entitlements)
        logger.info ("These entitlements has been successfully released: %s" %\
            entitlements)

def is_system_up(host):
    """ Sends Ping requests and checks whether device is up or not."""
    response = os.system("ping -c 1 " + host)
    return response == 0

def is_api_reachable(host, trailblazer_port=4431):
    """ It checks whether WSA's api_server is up or not."""
    if not is_system_up(host):
        return False
    connection_obj = http_client.HTTPConnection(host, trailblazer_port)
    try:
        connection_obj.connect()
    except Exception:
        return False
    return True

if __name__ == "__main__":
    import argparse

    def validate_args(args):
        """ It validates command line arguments. """
        if args.release_license:
            arg_value_map = {
                '--hostname': args.hostname,
            }
            for key, field in arg_value_map.items():
                if field is None:
                    raise Exception(f"{key} is a required argument, if "
                        f"'--release_license' argument is given.")
        else:
            arg_value_map = {
                '--hostname': args.hostname,
                '--smart_license_token': args.smart_license_token
            }
            for key, field in arg_value_map.items():
                if field is None:
                    raise Exception(f'{key} is a required argument.')
            data_fields = [args.data_interface_hostname, args.data_interface_ip,
                args.data_interface_netmask, args.data_interface_gateway_ip]
            if all(data_fields) != any(data_fields):
                raise Exception("Please pass all of these values or "\
                    "remove all: \n [--data_interface_hostname, "\
                    "--data_interface_ip, --data_interface_netmask, "\
                    "--data_interface_gateway_ip]")

    def get_arguments():
        """ It will parse command line arguments"""
        parser = argparse.ArgumentParser()
        parser.add_argument('-hn', '--hostname', \
            help="public hostname", type=str, required=True)
        parser.add_argument('-dh', '--data_interface_hostname', \
            help="data interface hostname", type=str)
        parser.add_argument('-di', '--data_interface_ip', \
            help="data interface ip", type=str)
        parser.add_argument('-dm', '--data_interface_netmask', \
            help="data interface netmask, eg: 16, 24 etc.", type=str)
        parser.add_argument('-dg', '--data_interface_gateway_ip', \
            help="data interface gateway ip", type=str)
        parser.add_argument('-tp', '--trailblazer_port', \
            help="Trailblazer port", type=str, default=4431)
        parser.add_argument('-us', '--username', \
            help="username (ex: admin)", default='admin', type=str)
        parser.add_argument('-pw', '--password', \
            help="Current password of device in base64 format (ex: aXJvbnBvcnQ=)", \
            default='aXJvbnBvcnQ=', type=str)
        parser.add_argument('-st', '--smart_license_token', \
            help="Smart License Registration Token", type=str, required=True)
        parser.add_argument('-sp', '--ssw_password', \
            help="SSW password", type=str, default='Q2lzY29AMTIz')
        parser.add_argument('-ne', '--notif_email', \
            help="Notification email", type=str, default='admin@cisco.com')
        parser.add_argument('-rl', '--release_license', dest='release_license', \
            help="Use this option without any value to release licences.", \
                action='store_true')
        parser.add_argument('-ll', '--log_level', help="Log level. "\
            "Possible values are [CRITICAL, ERROR, WARNING, INFO, DEBUG]", \
            choices=["CRITICAL", "ERROR", "WARNING", "INFO", "DEBUG"],
            default="INFO")

        args = parser.parse_args()
        return args

    args = get_arguments()
    validate_args(args)

    # set log level
    logger.setLevel(args.log_level)

    logger.info ("Checking wether system is up or not... ")
    start_time = time()
    while not is_api_reachable(args.hostname, args.trailblazer_port):
        logger.info (f"System {args.hostname} not up yet, "
            f"will check after {RETRY_INTERVAL} seconds... ")
        if time() - start_time > MAX_WAIT_FOR_DEVICE_UP:
            raise Exception(f"Even after {MAX_WAIT_FOR_DEVICE_UP} seconds, "
                f"device is not up. Exiting..." )
        sleep(RETRY_INTERVAL)

    logger.info (f"System {args.hostname} is up")
    url = f"https://{args.hostname}:{args.trailblazer_port}"

    try:
        boot_time_config = BootTimeConfig(url, args.username, args.password)
        boot_time_config.load_license(LOAD_LICENSE_PATH, args.smart_license_token)
        boot_time_config.perform_ssw(PERFORM_SSW_PATH, args.hostname, \
            args.data_interface_hostname, args.data_interface_ip, \
            args.data_interface_netmask, args.data_interface_gateway_ip, \
            args.ssw_password, args.notif_email)
        boot_time_config.request_smart_licensing_entitlements(\
            LICENSE_ENTITLEMENT_PATH)
    except Exception as err:
        logger.critical(f"Boot-time config failed with "
            f"following reason: {str(err)}")
        exit(1)
    logger.info ("Boot-time config, finished successfully")

