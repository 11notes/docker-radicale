# docker-radicale

Dockerfile to create and run a single radicale instance for CardDAV and CalDAV

## docker volumes

/config > Holds all the config information of radicale
/data > Stores the calendars, adressbooks and all other objects which must be persistent

## docker build

```shell
docker build -t YOURNAME/YOURCONTAINER:YOURTAG .
```

## docker run

```shell
docker run --name radicale \
    -v /YOUR/PATH/config:/config \
    -v /YOUR/PATH/data:/data \
    --restart unless-stopped \
    11notes/radicale:latest
```

## radicale create objects

Access the container via http://YOUR_IP:5232 and login as either one of the two default users (admin:1234, user:1234) or create new users first. You can then create the desired CalDAV or CardDAV objects.

## radicale auth

This radicale container will authenticate all users present in the /config/users file. You can add and remove users from the /config/users file by using htpasswd (either directly in the container or from a remote system).

```shell
htpasswd -B /config/users john
New password:
```

## radicale rights (ACL)

If you plan to use this container to create multiple calendars between different users you have to specify which user can access which calendars and adressbooks. To change rights edit the file /config/rights.

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

You can set access permission to r (read) or rw (read/write). Collection is the name of the object you want to give access to. By default radicale will create a folder under /data/collection-root for each user you have created and object for.

```shell
/data/collection-root/admin
```

If you need for instance a global adressbook for different users (most common use case), you can simply create a main user with a single addressbook. You'll end up with something like this.

```shell
/data/collection-root/main_user/a86bdf4f-ab9b-d944-c8ca-f5310cb54ac0/
```

To grant access to this users addressbook for other users you can just create a symbolic link to the same directory instead of creating a second addressbook.

```shell
cd /data/collection-root
ln -s main_user access_user
/data/collection-root/main_user
/data/collection-root/access_user -> main_user
```

The access_user doesn't have his own addressbook, but uses the same objects from the main_user. If now, you need only read only access for the access_user (which makes sense, change the rights to the following.

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

## build with

* [radicale](https://radicale.org/about/) - radicale CalDAV/CardDAV server (created by Kozea@github)

## tipps

* [alpine-docker-netshare](https://github.com/11notes/alpine-docker-netshare) - Examples to store persistent data on external storage systems
* [Outlook CalDAV/CardDAV sync](https://caldavsynchronizer.org/) - Plugin to sync outlook with any CalDAV or CardDAV server