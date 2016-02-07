provider "docker" {
	host = "unix:///var/run/docker.sock"
}

variable "uid" {
	type = "string"
	default = "797"
}

variable "gid" {
	type = "string"
	default = "797"
}

variable "nzbget_config_dir" {
	type = "string"
	default = "/var/lib/nzbget"
}

variable "sonarr_config_dir" {
	type = "string"
	default = "/var/lib/sonarr"
}

variable "couchpotato_config_dir" {
	type = "string"
	default = "/var/lib/couchpotato"
}

variable "plex_config_dir" {
	type = "string"
	default = "/var/lib/plex"
}

variable "media_dir" {
	type = "string"
}

variable "tv_dir" {
	type = "string"
}

variable "downloads_dir" {
	type = "string"
}

resource "docker_image" "nzbget" {
	name = "linuxserver/nzbget"
	keep_updated = true
}

resource "docker_image" "sonarr" {
	name = "linuxserver/sonarr"
	keep_updated = true
}

resource "docker_image" "couchpotato" {
	name = "linuxserver/couchpotato"
	keep_updated = true
}

resource "docker_image" "plex" {
	name = "wernight/plex-media-server"
	keep_updated = true
}

resource "docker_network" "private_network" {
  name = "htpc_network"
	check_duplicate = true
}

resource "docker_container" "nzbget" {
	name = "nzbget"
	image = "${docker_image.nzbget.latest}"
	hostname = "nzbget"
	restart ="always"
	must_run = true
	networks = ["${docker_network.private_network.id}"]
	ports = {
		internal = 6789
		external = 6789
	}
	env = [
		"PUID=${var.uid}",
		"PGID=${var.gid}"
	]
	volumes = {
		host_path = "/etc/localtime"
		container_path = "/etc/localtime"
		read_only = true
	}
	volumes = {
		host_path = "${var.nzbget_config_dir}"
		container_path = "/config"
	}
	volumes = {
		host_path = "${var.downloads_dir}"
		container_path = "/downloads"
	}
	depends_on = ["docker_network.private_network"]
}

resource "docker_container" "sonarr" {
	name = "sonarr"
	image = "${docker_image.sonarr.latest}"
	hostname = "sonarr"
	restart ="always"
	must_run = true
	networks = ["${docker_network.private_network.id}"]
	ports = {
		internal = 8989
		external = 8989
	}
	env = [
		"PUID=${var.uid}",
		"PGID=${var.gid}"
	]
	volumes = {
		host_path = "/etc/localtime"
		container_path = "/etc/localtime"
		read_only = true
	}
	volumes = {
		host_path = "/dev/rtc"
		container_path = "/dev/rtc"
		read_only = true
	}
	volumes = {
		host_path = "${var.sonarr_config_dir}"
		container_path = "/config"
	}
	volumes = {
		host_path = "${var.downloads_dir}"
		container_path = "/downloads"
	}
	volumes = {
		host_path = "${var.tv_dir}"
		container_path = "/tv"
	}
	depends_on = ["docker_container.nzbget"]
}

resource "docker_container" "couchpotato" {
	name = "couchpotato"
	image = "${docker_image.couchpotato.latest}"
	hostname = "couchpotato"
	restart ="always"
	must_run = true
	networks = ["${docker_network.private_network.id}"]
	ports = {
		internal = 5050
		external = 5050
	}
	env = [
		"PUID=${var.uid}",
		"PGID=${var.gid}"
	]
	volumes = {
		host_path = "/etc/localtime"
		container_path = "/etc/localtime"
		read_only = true
	}
	volumes = {
		host_path = "${var.couchpotato_config_dir}"
		container_path = "/config"
	}
	volumes = {
		host_path = "${var.downloads_dir}"
		container_path = "/downloads"
	}
	volumes = {
		host_path = "${var.media_dir}"
		container_path = "/media"
	}
	depends_on = ["docker_container.nzbget"]
}

resource "docker_container" "plex" {
	name = "plex"
	image = "${docker_image.plex.latest}"
	hostname = "plex"
	restart ="always"
	must_run = true
	networks = ["${docker_network.private_network.id}"]
	ports = {
		internal = 32400
		external = 32400
	}
	ports = {
		internal = 32410
		external = 32410
		protocol = "udp"
	}
	ports = {
		internal = 32412
		external = 32412
		protocol = "udp"
	}
	ports = {
		internal = 32413
		external = 32413
		protocol = "udp"
	}
	ports = {
		internal = 32414
		external = 32414
		protocol = "udp"
	}
	volumes = {
		host_path = "/etc/localtime"
		container_path = "/etc/localtime"
		read_only = true
	}
	volumes = {
		host_path = "${var.plex_config_dir}"
		container_path = "/config"
	}
	volumes = {
		host_path = "${var.media_dir}"
		container_path = "/media"
	}
	depends_on = ["docker_container.sonarr", "docker_container.couchpotato"]
}
