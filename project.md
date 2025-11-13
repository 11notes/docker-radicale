${{ image: Dashboard.png }}

${{ content_synopsis }} This image will give you a [rootless](https://github.com/11notes/RTFM/blob/main/linux/container/image/rootless.md) and leightweight Radicale installation.

${{ content_uvp }} Good question! Because ...

${{ github:> [!IMPORTANT] }}
${{ github:> }}* ... this image runs [rootless](https://github.com/11notes/RTFM/blob/main/linux/container/image/rootless.md) as 1000:1000
${{ github:> }}* ... this image is auto updated to the latest version via CI/CD
${{ github:> }}* ... this image is built and compiled from source
${{ github:> }}* ... this image has a health check
${{ github:> }}* ... this image runs read-only
${{ github:> }}* ... this image is automatically scanned for CVEs before and after publishing
${{ github:> }}* ... this image is created via a secure and pinned CI/CD process
${{ github:> }}* ... this image is very small

If you value security, simplicity and optimizations to the extreme, then this image might be for you.

${{ content_comparison }}

${{ title_volumes }}
* **${{ json_root }}/etc** - Directory of your configs
* **${{ json_root }}/var** - Directory of calendars and address books

${{ content_compose }}

${{ content_defaults }}

${{ content_environment }}
| `RADICALE_CONFIG` | Inline config written to /radicale/etc/default.conf | |
| `RADICALE_RIGHTS` | Inline config written to /radicale/etc/rights | |
| `RADICALE_USERS` | Inline config written to /radicale/etc/users | |

${{ content_source }}

${{ content_parent }}

${{ content_built }}

${{ content_tips }}