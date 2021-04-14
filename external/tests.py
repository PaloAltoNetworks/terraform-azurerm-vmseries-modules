from configure_panorama import connect, gen_bootstrap, show_bootstrap, bootstrap, gen_inbound_init_cfgs, parse_args, upload_cfgs, upload_licenses
import os

if __name__ == '__main__':
    """
    Run a set of integration tests if we're called from the command line
    You must configure environment varibles that map to a real instance of Panorama.
        WINDOWS
            set P_HOSTNAME=1.1.1.1
            set P_USERNAME=admin
            set P_PASSWORD=whatever
        NIX
            export P_HOSTNAME=1.1.1.1
            export P_USERNAME=admin
            export P_PASSWORD=whatever
    """
    query = {
        "panorama_ip": os.getenv("P_HOSTNAME"),
        "username": os.getenv("P_USERNAME"),
        "password": os.getenv("P_PASSWORD"),
        "panorama_private_ip": "10.10.10.10",
        "storage_account_name": "test",
        "storage_account_key": "test",
        "inbound_storage_share_name": "test-ib",
        "outbound_storage_share_name": "test-ob",
        "key_lifetime": "8760",
        "output_dir": os.getcwd()
    }
    query = parse_args(query)
    r = gen_inbound_init_cfgs(query, "012345678910")
    r = upload_licenses(query)

