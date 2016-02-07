# terraform-plex
Terraform Script for Sonarr + CouchPotato + NZBGet + Plex Server

## Requirements
- docker
- terraform

## Installation

- Create the user and group corresponding to `uid` and `gid` vars.
- Create the config directories as outlined below for each application and chown them with the above user and group.
- `terraform apply .`
- Apps should be accessible on their given ports
- Configure the media, tv and downloads paths through app UI as required.

## Terraform Vars
| Var | Description | Default |
| --- | ----------- | ------- |
| `uid` | id of user that owns config directories on host and of user that runs containers | `797` |
| `gid` | id of group that owns config directories on host and of group that runs containers | `797` |
| `nzbget_config_dir` | directory on host that stores NZBGet config data | `/var/lib/nzbget` |
| `sonarr_config_dir` | directory on host that stores Sonarr config data | `/var/lib/sonarr` |
| `couchpotato_config_dir` | directory on host that stores CouchPotato config data | `/var/lib/couchpotato` |
| `plex_config_dir` | directory on host that stores Plex Media Server config data | `/var/lib/plex` |
| `media_dir` | directory on the host that stores all media files. | N/A |
| `tv_dir` | directory on the host that stores tv files. | N/A |
| `downloads_dir` | directory on the host that stores downloads, assumes both incomplete and complete files are in this directory or sub-directories | N/A |

## Containers

### NZBGet

https://hub.docker.com/r/linuxserver/nzbget/

Accessible on port `6789`.

Mounts the following directories:

| Config Var | Mount Point |
| ---------- | ----------- |
| `nzbget_config_dir` | `/config` |
| `downloads_dir` | `/downloads` |

### Sonarr

https://hub.docker.com/r/linuxserver/sonarr/

Accessible on port `8989`.

Mounts the following directories:

| Config Var | Mount Point |
| ---------- | ----------- |
| `sonarr_config_dir` | `/config` |
| `downloads_dir` | `/downloads` |
| `tv_dir` | `/tv` |

### CouchPotato

https://hub.docker.com/r/linuxserver/couchpotato/

Accessible on port `5050`.

Mounts the following directories:

| Config Var | Mount Point |
| ---------- | ----------- |
| `couchpotato_config_dir` | `/config` |
| `downloads_dir` | `/downloads` |
| `media_dir` | `/media` |

### Plex Media Server

https://hub.docker.com/r/wernight/plex-media-server/

Accessible on port `32400`.

Mounts the following directories:

| Config Var | Mount Point |
| ---------- | ----------- |
| `plex_config_dir` | `/config` |
| `media_dir` | `/media` |

NB: The `allowedNetworks` setting will likely need to be configured to make Plex and the Server tab accessible: https://support.plex.tv/hc/en-us/articles/201105343-Advanced-Server-Settings. Configure this after the container has been started for the first time, then issue `docker restart plex`.
