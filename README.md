![banner](https://raw.githubusercontent.com/11notes/static/refs/heads/main/img/banner/README.png)

# RADICALE
![size](https://img.shields.io/badge/image_size-69MB-green?color=%2338ad2d)![5px](https://raw.githubusercontent.com/11notes/static/refs/heads/main/img/markdown/transparent5x2px.png)![pulls](https://img.shields.io/docker/pulls/11notes/radicale?color=2b75d6)![5px](https://raw.githubusercontent.com/11notes/static/refs/heads/main/img/markdown/transparent5x2px.png)[<img src="https://img.shields.io/github/issues/11notes/docker-radicale?color=7842f5">](https://github.com/11notes/docker-radicale/issues)![5px](https://raw.githubusercontent.com/11notes/static/refs/heads/main/img/markdown/transparent5x2px.png)![swiss_made](https://img.shields.io/badge/Swiss_Made-FFFFFF?labelColor=FF0000&logo=data:image/svg%2bxml;base64,PHN2ZyB2ZXJzaW9uPSIxIiB3aWR0aD0iNTEyIiBoZWlnaHQ9IjUxMiIgdmlld0JveD0iMCAwIDMyIDMyIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgogIDxyZWN0IHdpZHRoPSIzMiIgaGVpZ2h0PSIzMiIgZmlsbD0idHJhbnNwYXJlbnQiLz4KICA8cGF0aCBkPSJtMTMgNmg2djdoN3Y2aC03djdoLTZ2LTdoLTd2LTZoN3oiIGZpbGw9IiNmZmYiLz4KPC9zdmc+)

Run rootless radicale

# INTRODUCTION 📢

[radicale](https://github.com/Kozea/Radicale) (created by [Kozea](https://github.com/Kozea/)) is a small but powerful CalDAV (calendars, to-do lists) and CardDAV (contacts) server.

image Dashboard.png not found!

# SYNOPSIS 📖
**What can I do with this?** This image will give you a [rootless](https://github.com/11notes/RTFM/blob/main/linux/container/image/rootless.md) and leightweight Radicale installation.

# UNIQUE VALUE PROPOSITION 💶
**Why should I run this image and not the other image(s) that already exist?** Good question! Because ...

> [!IMPORTANT]
>* ... this image runs [rootless](https://github.com/11notes/RTFM/blob/main/linux/container/image/rootless.md) as 1000:1000
>* ... this image is auto updated to the latest version via CI/CD
>* ... this image is built and compiled from source
>* ... this image has a health check
>* ... this image runs read-only
>* ... this image is automatically scanned for CVEs before and after publishing
>* ... this image is created via a secure and pinned CI/CD process
>* ... this image is very small

If you value security, simplicity and optimizations to the extreme, then this image might be for you.

# COMPARISON 🏁
Below you find a comparison between this image and the most used or original one.

| **image** | **size on disk** | **init default as** | **[distroless](https://github.com/11notes/RTFM/blob/main/linux/container/image/distroless.md)** | supported architectures
| ---: | ---: | :---: | :---: | :---: |
| 11notes/radicale | 69MB | 1000:1000 | ❌ | amd64, arm64, armv7 |
| kozea/radicale | 80MB | 1000:1000 | ❌ | amd64, arm64 |

# VOLUMES 📁
* **/radicale/etc** - Directory of your configs
* **/radicale/var** - Directory of calendars and address books

# COMPOSE ✂️
```yaml
name: "caldav"

x-lockdown: &lockdown
  # prevents write access to the image itself
  read_only: true
  # prevents any process within the container to gain more privileges
  security_opt:
    - "no-new-privileges=true"

services:
  radicale:
    image: "11notes/radicale:3.5.8"
    <<: *lockdown
    environment:
      TZ: "Europe/Zurich"
      RADICALE_RIGHTS: |-
        [_]
        user: .+
        collection:
        permissions: R

        [user]
        user: .+
        collection: {user}
        permissions: RW

        [user-inherit]
        user: .+
        collection: {user}/[^/]+
        permissions: rw
      RADICALE_USERS: |-
        admin:$argon2i$v=19$m=16,t=2,p=1$YzUzMjQyMzUz$ZsEZ3NpmuKPRJ92gfuzZRA
    ports:
      - "3000:5232/tcp"
    networks:
      frontend:
    volumes:
      - "radicale.etc:/radicale/etc"
      - "radicale.var:/radicale/var"
    restart: "always"

volumes:
  radicale.etc:
  radicale.var:

networks:
  frontend:
```
To find out how you can change the default UID/GID of this container image, consult the [RTFM](https://github.com/11notes/RTFM/blob/main/linux/container/image/11notes/how-to.changeUIDGID.md#change-uidgid-the-correct-way).

# DEFAULT SETTINGS 🗃️
| Parameter | Value | Description |
| --- | --- | --- |
| `user` | docker | user name |
| `uid` | 1000 | [user identifier](https://en.wikipedia.org/wiki/User_identifier) |
| `gid` | 1000 | [group identifier](https://en.wikipedia.org/wiki/Group_identifier) |
| `home` | /radicale | home directory of user docker |

# ENVIRONMENT 📝
| Parameter | Value | Default |
| --- | --- | --- |
| `TZ` | [Time Zone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) | |
| `DEBUG` | Will activate debug option for container image and app (if available) | |
| `RADICALE_CONFIG` | Inline config written to /radicale/etc/default.conf | |
| `RADICALE_RIGHTS` | Inline config written to /radicale/etc/rights | |
| `RADICALE_USERS` | Inline config written to /radicale/etc/users | |

# MAIN TAGS 🏷️
These are the main tags for the image. There is also a tag for each commit and its shorthand sha256 value.

* [3.5.8](https://hub.docker.com/r/11notes/radicale/tags?name=3.5.8)

### There is no latest tag, what am I supposed to do about updates?
It is my opinion that the ```:latest``` tag is a bad habbit and should not be used at all. Many developers introduce **breaking changes** in new releases. This would messed up everything for people who use ```:latest```. If you don’t want to change the tag to the latest [semver](https://semver.org/), simply use the short versions of [semver](https://semver.org/). Instead of using ```:3.5.8``` you can use ```:3``` or ```:3.5```. Since on each new version these tags are updated to the latest version of the software, using them is identical to using ```:latest``` but at least fixed to a major or minor version. Which in theory should not introduce breaking changes.

If you still insist on having the bleeding edge release of this app, simply use the ```:rolling``` tag, but be warned! You will get the latest version of the app instantly, regardless of breaking changes or security issues or what so ever. You do this at your own risk!

# REGISTRIES ☁️
```
docker pull 11notes/radicale:3.5.8
docker pull ghcr.io/11notes/radicale:3.5.8
docker pull quay.io/11notes/radicale:3.5.8
```

# SOURCE 💾
* [11notes/radicale](https://github.com/11notes/docker-radicale)

# PARENT IMAGE 🏛️
* [${{ json_readme_parent_image }}](${{ json_readme_parent_url }})

# BUILT WITH 🧰
* [Kozea/Radicale](https://github.com/Kozea/Radicale)
* [11notes/util](https://github.com/11notes/docker-util)

# GENERAL TIPS 📌
> [!TIP]
>* Use a reverse proxy like Traefik, Nginx, HAproxy to terminate TLS and to protect your endpoints
>* Use Let’s Encrypt DNS-01 challenge to obtain valid SSL certificates for your services

# ElevenNotes™️
This image is provided to you at your own risk. Always make backups before updating an image to a different version. Check the [releases](https://github.com/11notes/docker-radicale/releases) for breaking changes. If you have any problems with using this image simply raise an [issue](https://github.com/11notes/docker-radicale/issues), thanks. If you have a question or inputs please create a new [discussion](https://github.com/11notes/docker-radicale/discussions) instead of an issue. You can find all my other repositories on [github](https://github.com/11notes?tab=repositories).

*created 13.11.2025, 11:24:36 (CET)*