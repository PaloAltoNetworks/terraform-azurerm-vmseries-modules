# Priority map of security rules for your management IP addresses.
# Each key is the public IP, and the number is the priority it gets in the relevant network security groups (NSGs).
management_ips = {
  "199.199.199.199" : 100,
}

# Optional Load Balancer (LB) rules
# These will automatically create a public Azure IP and associate to LB configuration.
frontend_ips = {
  "frontend01" = {
    create_public_ip = true
    rules = {
      "testssh" = {
        protocol = "Tcp"
        port     = 22
      }
    }
  }
}
