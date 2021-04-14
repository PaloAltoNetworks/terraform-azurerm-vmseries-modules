from terraform_external_data import terraform_external_data
from panosxml import Panos
import re
import urllib3
urllib3.disable_warnings()
from xml.etree import ElementTree
from constants import *
import os
import subprocess
import time
import argparse

OUTPUT_DIR="upload"
LICENSE_DIR="license"


REQUIRED_ARGS=[
    "panorama_ip",
    "username",
    "password",
    "panorama_private_ip",
    "storage_account_name",
    "storage_account_key",
    "inbound_storage_share_name",
    "outbound_storage_share_name",
]

OPTIONAL_ARGS={
    "key_lifetime": "8759",
    "output_dir": os.getcwd(),
    "outbound_hostname": "outside-fw",
    "outbound_device_group": "OUTBOUND",
    "outbound_template_stack": "OUTBOUND",
    "inbound_hostname": "inside-fw",
    "inbound_device_group": "INBOUND",
    "inbound_template_stack": "INBOUND",
    "dns_server": "8.8.8.8",
}


def connect(query: dict):
    connected = False
    failures = 0
    # Retry for 30 minutes
    max_failures = 60
    while not connected:
        if failures >= max_failures:
            raise PanoramaError("Failed to connect to panorama at {}".format(query["panorama_ip"]))
        try:
            p = Panos(query["panorama_ip"], user=query["username"], pw=query["password"])
            connected = True
        except:
            failures = failures +1
            time.sleep(30)
            pass

    return p

def gen_inbound_init_cfgs(query: dict, vm_auth_key:str):
    inbound_config = init_cfg(
        hostname=query["inbound_hostname"],
        vm_auth_key=vm_auth_key,
        device_group_name=query["inbound_device_group"],
        template_name=query["inbound_template_stack"],
        panorama_ip=query["panorama_private_ip"],
        dns_ip=query["dns_server"]
    )
    fp = os.path.join(query["output_dir"], OUTPUT_DIR, "init-cfg-inbound.txt")
    fd = os.path.join(query["output_dir"], OUTPUT_DIR)
    if not os.path.isdir(fd):
        os.mkdir(fd)

    fh = open(fp, mode="w")
    fh.write(inbound_config)
    fh.close()

    return fp

def gen_outbound_init_cfgs(query: dict, vm_auth_key:str):
    outbound_config = init_cfg(
        hostname=query["outbound_hostname"],
        vm_auth_key=vm_auth_key,
        device_group_name=query["outbound_device_group"],
        template_name=query["outbound_template_stack"],
        panorama_ip=query["panorama_private_ip"],
        dns_ip=query["dns_server"]
    )

    fp = os.path.join(query["output_dir"], OUTPUT_DIR, "init-cfg-outbound.txt")
    fd = os.path.join(query["output_dir"], OUTPUT_DIR)
    if not os.path.isdir(fd):
        os.mkdir(fd)

    fh = open(fp, mode="w")
    fh.write(outbound_config)
    fh.close()

    return fp


def upload_cfgs(path,
                storage_account_name,
                primary_access_key,
                storage_share_name
                ):
    results = []
    cmd = f"az storage file upload --account-name {storage_account_name} --account-key {primary_access_key} --share-name {storage_share_name} --source {path} --path config/init-cfg.txt"
    r = subprocess.run(
        cmd.split(),
        shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=True,
    )
    results.append(r)
    return results


def upload_license(path,
                storage_account_name,
                primary_access_key,
                storage_share_name
                ):
    results = []
    cmd = f"az storage file upload-batch --account-name {storage_account_name} --account-key {primary_access_key} --destination {storage_share_name} --source {path} --destination-path license"
    r = subprocess.run(
        cmd.split(), shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE
    )
    results.append(r)
    return results


def gen_bootstrap(p: Panos, lifetime: str):
    """
    Gen a new Bootstrap key
    """
    params = {
        "type": "op",
        "cmd": "<request><bootstrap><vm-auth-key><generate><lifetime>{}</lifetime></generate></vm-auth-key></bootstrap></request>".format(lifetime)
    }
    r = p.send(params)
    if not p.check_resp(r):
        raise PanoramaError("Failed to generate Bootstrap key {}".format(r.content))

    regex_result = re.search("VM auth key\s+(\d+)\s+", r.content.decode())
    key = regex_result.group(1)

    return key


def show_bootstrap(p: Panos):
    """
    Get the most recently generated bootstrap key
    """
    params = {
        "type": "op",
        "cmd": "<request><bootstrap><vm-auth-key><show></show></vm-auth-key></bootstrap></request>"
    }
    r = p.send(params)
    if not p.check_resp(r):
        raise PanoramaError("Failed to show Bootstrap key.")

    root = ElementTree.fromstring(r.content.decode())
    keys = root.findall("./result/bootstrap-vm-auth-keys/entry/vm-auth-key")
    if len(keys) == 0:
        return

    return keys[0].text


def upload_licenses(query):
    """
    Upload any licenses that are stored in the "upload" directory
    :param query:
    :return:
    """
    license_dir = os.path.join(query["output_dir"], LICENSE_DIR)
    if not os.path.isdir(license_dir):
        return
    upload_license(
        license_dir,
        storage_account_name=query["storage_account_name"],
        storage_share_name=query["inbound_storage_share_name"],
        primary_access_key=query["storage_account_key"]
    )
    upload_license(
        license_dir,
        storage_account_name=query["storage_account_name"],
        storage_share_name=query["outbound_storage_share_name"],
        primary_access_key=query["storage_account_key"]
    )


def bootstrap(query):
    p = connect(query)
    key = show_bootstrap(p)
    # never yet bootstratpped
    if not key:
        key = gen_bootstrap(p, query["key_lifetime"])
        inbound_config = gen_inbound_init_cfgs(query, key)
        outbound_config = gen_outbound_init_cfgs(query, key)
        upload_cfgs(
            inbound_config,
            storage_account_name=query["storage_account_name"],
            storage_share_name=query["inbound_storage_share_name"],
            primary_access_key=query["storage_account_key"]
        )
        upload_cfgs(
            outbound_config,
            storage_account_name=query["storage_account_name"],
            storage_share_name=query["outbound_storage_share_name"],
            primary_access_key=query["storage_account_key"]
        )

    upload_licenses(query)
    return key


def parse_args(query: dict):
    for a in REQUIRED_ARGS:
        if a not in query:
            raise ValueError("Missing required argument {}".format(a))

    for k, v in OPTIONAL_ARGS.items():
        if k not in query:
            query[k] = v

    return query

def argparse_to_query(cli_args):
    query = {}
    for a in REQUIRED_ARGS:
        if not cli_args.__getattribute__(a):
            raise ValueError("Missing required argument {}".format(a))
        else:
            query[a] = cli_args.__getattribute__(a)

    for k, v in OPTIONAL_ARGS.items():
        if not cli_args.__getattribute__(k):
            query[k] = v
        else:
            query[k] = cli_args.__getattribute__(k)


    return query

@terraform_external_data
def main(query):
    r = {}

    query = parse_args(query)
    r['vm-auth-key'] = bootstrap(query)
    r['status'] = "OK"
    return r

def main_cli(cli_args):
    r = {}

    query = argparse_to_query(cli_args)
    r['vm-auth-key'] = bootstrap(query)
    r['status'] = "OK"

    return r

class PanoramaError(Exception):
    pass


if __name__ == '__main__':
    p = argparse.ArgumentParser(description="Bootstrap Panorama from the command line.")
    p.add_argument("--panorama_ip", "-pp", help="Panorama Public IP address")
    p.add_argument("--username", "-u", help="Username to use for accessing Panorama", default=os.environ.get("USERNAME"))
    p.add_argument("--password", "-p", help="Password to use for accessing Panorama", default=os.environ.get("PASSWORD"))
    p.add_argument("--panorama_private_ip", "-pip", help="Private IP address for Panorama")
    p.add_argument("--storage_account_name", "-sn", help="Storage account name")
    p.add_argument("--storage_account_key", "-sk", help="Storage account key (primary access key)")
    p.add_argument("--inbound_storage_share_name", "-iss", help="Inbound storage share name")
    p.add_argument("--outbound_storage_share_name", "-oss", help="Outbound  storage share name")


    for k, v in OPTIONAL_ARGS.items():
        p.add_argument(f"--{k}", default=v, metavar=f"Default: {v}")

    args = p.parse_args()
    if args.panorama_ip:
        main_cli(args)
    else:
        main()
