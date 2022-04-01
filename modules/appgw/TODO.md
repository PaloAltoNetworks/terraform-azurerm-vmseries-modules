# TODO

- [x] test everything in V2
- [ ] add WAF support ??
- [x] add custom ssl support on the backend traffic
- [x] add possibility to create custom ssl policies
- [x] ssl profiles for v2
- [x] custom error configuration for http_listeners
- [x] ~~check if priority can be use in v2~~ - no, it's not for listeners
- [x] multiple listeners on the same port for multi-site domains
- [x] update documentation on the full set of properties in `rules` map
- [ ] should we use `allow_inbound_mgmt_ips`
- [x] think about the http settings vs probe: probe can be used w/o hostname only if we override the hostname in http settings. if we do not do it, we have to specify a probe that overrides a hostname

- [ ] aws - `type` to the bottom of the `variable` block
