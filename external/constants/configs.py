
def init_cfg(hostname, vm_auth_key, device_group_name, template_name, panorama_ip, dns_ip):
    r = f"""
ip-address=
default-gateway=
netmask=
ipv6-address=
ipv6-default-gateway=
hostname={hostname}
vm-auth-key={vm_auth_key}
panorama-server={panorama_ip}
tplname={template_name}
dgname={device_group_name}
dns-primary={dns_ip}
dhcp-send-hostname=yes
dhcp-send-client-id=yes
dhcp-accept-server-hostname=yes
dhcp-accept-server-domain=yes
"""
    return r
