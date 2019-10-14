# docker-radicale

Dockerfile to create and run a single radicale instance for CardDAV and CalDAV.

## Volumes

/radicale/etc

Purpose: Holds all the config information of radicale

/radicale/var

Purpose: Stores the calendars, adressbooks and all other objects


## Run
```shell
docker run --name radicale \
    -v volume-etc:/radicale/etc \
    -v volume-var:/radicale/var \
    -d 11notes/radicale:[tag]
```

## Defaults
* HTTP 401 / admin:foo, user:bar (/radicale/etc/users) - please change with bcrypt!

## radicale create objects

Access the container via http://YOUR_IP:5232 and login as either one of the two default users (admin:1234, user:1234) or create new users first. You can then create the desired CalDAV or CardDAV objects.

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

## Docker -u 1000:1000 (no root initiative)

As part to make containers more secure, this container will not run as root, but as uid:gid 1000:1000.

## Build with
* [Alpine Linux](https://alpinelinux.org/) - Alpine Linux
* [radicale](https://radicale.org/about/) - radicale CalDAV/CardDAV server (created by Kozea@github)

## Tips

* Don't bind to ports < 1024 (requires root), use NAT
* [Permanent Storge with NFS/CIFS/...](https://github.com/11notes/alpine-docker-netshare) - Module to store permanent container data via NFS/CIFS/...
* [Outlook CalDAV/CardDAV sync](https://caldavsynchronizer.org/) - Plugin to sync outlook with any CalDAV or CardDAV server