# Priority map of security rules for your management IP addresses.
# Each key is the public IP, and the number is the priority it gets in the relevant network security groups (NSGs).
management_ips = {
  "199.199.199.199" : 100,
}

# Optional Load Balancer (LB) rules
# These will automatically create a public Azure IP and associate to LB configuration.
rules = {
  "myssh" = {
    protocol = "Tcp"
    port     = 22
  }
}

# The count here defines how many VM-series are deployed PER VM direction (inbound/outbound)
vm_series_count = 2
