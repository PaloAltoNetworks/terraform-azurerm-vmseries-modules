- [x] port 80 listener > redirect to 443
- [ ] (it's just a matter of configuration) configure HTTPS to use a custom health probe: http probe to port 1010 (for probing the firewall loopback port instead of the backend resource)
- [x] https listener: pull the certificate from the keyvault
- [ ] customize XFF header: do not include the port number (default AppGW behavior, but our firewalls cannot digest it)
- [ ] add another header (hardcode in): X-Forwarded-Proto: https (since after the redirection all traffic is https at the AppGW, but forwarded as HTTP, some applications require it)
- [ ] (maybe / consider what would it take) modify all cookies to HTTP only: {http_resp_Set-Cookie_1};HttpOnly;Secure
- [ ] add documentation - examples on different use cases

- [ ] check if `hcl` markers in code blocks render properly for README's