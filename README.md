![Banner](https://github.com/11notes/defaults/blob/main/static/img/banner.png?raw=true)

# 🏔️ Alpine - Radicale
![size](https://img.shields.io/docker/image-size/11notes/radicale/3.1.8?color=0eb305) ![version](https://img.shields.io/docker/v/11notes/radicale/3.1.8?color=eb7a09) ![pulls](https://img.shields.io/docker/pulls/11notes/radicale?color=2b75d6) ![activity](https://img.shields.io/github/commit-activity/m/11notes/docker-radicale?color=c91cb8) ![commit-last](https://img.shields.io/github/last-commit/11notes/docker-radicale?color=c91cb8) ![stars](https://img.shields.io/docker/stars/11notes/radicale?color=e6a50e)

**CalDAV and CardDAV server with LDAP/AD authentication**

# SYNOPSIS
What can I do with this? This image will run [Radicale](https://radicale.org/) with an additional LDAP/AD authentication plugin. You can use this image to store or share calendars or address books, or both. Create fine grained ACL via the `rights` config, where you can give certain people read-only access to objects in your shared address books or calendars.

# VOLUMES
* **/radicale/etc** - Directory of default.conf
* **/radicale/var** - Directory of all calendars, adressbooks and all other objects
* **/radicale/ssl** - Directory of ssl certificates for TLS

# RUN
```shell
docker run --name radicale \
  -v .../etc:/radicale/etc \
  -v .../var:/radicale/var \
  -d 11notes/radicale:[tag]
```

# EXAMPLES
## config /radicale/etc/default.conf
```ini
[server]
ssl = True
hosts = 0.0.0.0:5232
max_connections = 1024
max_content_length = 52428800
certificate = /radicale/ssl/cert.pem
key = /radicale/ssl/key.pem

[storage]
type = multifilesystem_nolock
filesystem_folder = /radicale/var

[auth]
type = htpasswd
htpasswd_filename = /radicale/etc/users
htpasswd_encryption = bcrypt

[rights]
type = from_file
file = /radicale/etc/rights
```

## config /radicale/etc/default.conf with LDAP/AD
```ini
[server]
ssl = True
hosts = 0.0.0.0:5232
max_connections = 1024
max_content_length = 52428800
certificate = /radicale/ssl/cert.pem
key = /radicale/ssl/key.pem

[storage]
type = multifilesystem_nolock
filesystem_folder = /radicale/var

[auth]
type = radicale_auth_ldap
ldap_url = ldap://domain.com:389
ldap_base = DC=domain,DC=com
ldap_attribute = userPrincipalName
ldap_filter = (objectCategory=person)(objectClass=user)(memberOf:1.2.840.113556.1.4.1941:=CN=Radicale Users,DC=domain,DC=com)
ldap_binddn = CN=ldap.radicale,DC=domain,DC=com
ldap_password = *************

[rights]
type = from_file
file = /radicale/etc/rights
```

# DEFAULT SETTINGS
| Parameter | Value | Description |
| --- | --- | --- |
| `user` | docker | user docker |
| `uid` | 1000 | user id 1000 |
| `gid` | 1000 | group id 1000 |
| `home` | /radicale | home directory of user docker |
| `config` | /radicale/etc/default.yaml | config |
| `rights` | /radicale/etc/rights | ACL |
| `users` | /radicale/etc/users | users for bcrypt authentication |
| `users:admin` | password for admin user (demo) | 1234 |

# ENVIRONMENT
| Parameter | Value | Default |
| --- | --- | --- |
| `TZ` | [Time Zone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) | |
| `DEBUG` | Show debug information | |

# PARENT IMAGE
* [11notes/alpine:stable](https://hub.docker.com/r/11notes/alpine)

# BUILT WITH
* [radicale](https://radicale.org/)
* [alpine](https://alpinelinux.org)

# TIPS
* Only use rootless container runtime (podman, rootless docker)
* Allow non-root ports < 1024 via `echo "net.ipv4.ip_unprivileged_port_start=53" > /etc/sysctl.d/ports.conf`
* Use a reverse proxy like Traefik, Nginx to terminate TLS with a valid certificate
* Use Let’s Encrypt certificates to protect your SSL endpoints

# ElevenNotes<sup>™️</sup>
This image is provided to you at your own risk. Always make backups before updating an image to a new version. Check the changelog for breaking changes.
    