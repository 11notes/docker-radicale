# Alpine :: Radicale
![size](https://img.shields.io/docker/image-size/11notes/radicale/3.1.8?color=0eb305) ![version](https://img.shields.io/docker/v/11notes/radicale?color=eb7a09) ![pulls](https://img.shields.io/docker/pulls/11notes/radicale?color=2b75d6) ![activity](https://img.shields.io/github/commit-activity/m/11notes/docker-radicale?color=c91cb8) ![commit-last](https://img.shields.io/github/last-commit/11notes/docker-radicale?color=c91cb8)

Run Radicale based on Alpine Linux. Small, lightweight, secure and fast 🏔️

## Volumes
* **/radicale/etc** - Directory of radicale configuration
* **/radicale/var** - Directory of calendars, adressbooks and all other objects

## Run
```shell
docker run --name radicale \
  -p 5232:5232 \
  -v ../etc:/radicale/etc \
  -v ../var:/radicale/var \
  -d 11notes/radicale:[tag]
```

## Defaults
| Parameter | Value | Description |
| --- | --- | --- |
| `user` | docker | user docker |
| `uid` | 1000 | user id 1000 |
| `gid` | 1000 | group id 1000 |
| `home` | /radicale | home directory of user docker |
| `web` | https://${IP}:5232 | default web ui |
| `config` | /radicale/etc/default.conf | default config location |
| `ssl` | /radicale/ssl | SSL is enabled by default |

## radicale create objects
Access the container via https://${IP}:5232 and login as either one of the two default users (admin:1234, user:1234) or create new users first. You can then create the desired CalDAV or CardDAV objects.

## radicale auth
This radicale container will authenticate all users present in the /radicale/etc/users file. You can add and remove users from the /radicale/etc/users file by using htpasswd (either directly in the container or from a remote system).

```shell
htpasswd -B /radicale/etc/users john
New password:
```

## radicale rights (ACL)
If you plan to use this container to create multiple addressbooks between different users you have to specify which user can access which adressbooks. To change rights edit the file /radicale/etc/rights.

```shell
[admin]
user: admin
collection: .*
permission: rw

[user]
user: user
collection: .*
permission: r
```

You can set access permission to r (read) or rw (read/write). Collection is the name of the object you want to give access to. By default radicale will create a folder under /radicale/var/collection-root for each user you have created and object for.

```shell
/radicale/var/collection-root/admin
```

If you need for instance a global adressbook for different users (most common use case), you can simply create a main user with a single addressbook. You'll end up with something like this.

```shell
/radicale/var/collection-root/main_user/a86bdf4f-ab9b-d944-c8ca-f5310cb54ac0/
```

To grant access to this users addressbook for other users you can just create a symbolic link to the same directory instead of creating a second addressbook.

```shell
cd /radicale/var/collection-root
ln -s main_user access_user
/radicale/var/collection-root/main_user
/radicale/var/collection-root/access_user -> main_user
```

The access_user doesn't have his own addressbook, but uses the same objects from the main_user. If now, you need only read only access for the access_user (which makes sense), change the rights to the following.

```shell
[global]
user: main_user
collection: main_user
permission: rw

[access]
user: access_user
collection: main_user
permission: r
```

If the access_user has his own addressbook & the global addressbook, just remove the symbolic link for access_user but leave the rights to be able to read the main_user addressbook. The collection name supports RegExp.

## Parent image
* [11notes/nginx:stable](https://github.com/11notes/docker-nginx)

## Built with and thanks to
* [radicale](https://radicale.org/about)
* [Alpine Linux](https://alpinelinux.org)

## Tips
* Do not expose container directly to the internet, use reverse proxy with ingress control and valid SSL certificate chain
* Only use rootless container runtime (podman, rootless docker)
* Don't bind to ports < 1024 (requires root), use NAT/reverse proxy (haproxy, traefik, nginx)