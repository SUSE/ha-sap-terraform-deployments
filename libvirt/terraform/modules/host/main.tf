terraform {
  required_version = "~> 0.11.7"
}

// Names are calculated as follows:
// ${var.base_configuration["name_prefix"]}${var.name}${var.count > 1 ? "-${count.index  + 1}" : ""}
// This means:
//   name_prefix + name (if count = 1)
//   name_prefix + name + "-" + index (if count > 1)

resource "libvirt_volume" "main_disk" {
  name             = "${var.base_configuration["name_prefix"]}${var.name}${var.count > 1 ? "-${count.index  + 1}" : ""}-main-disk"
  base_volume_name = "${var.base_configuration["use_shared_resources"] ? "" : var.base_configuration["name_prefix"]}baseimage"
  pool             = "${var.base_configuration["pool"]}"
  count            = "${var.count}"
}

resource "libvirt_volume" "hana_disk" {
  name  = "${var.base_configuration["name_prefix"]}${var.name}${var.count > 1 ? "-${count.index  + 1}" : ""}-hana-disk"
  pool  = "${var.base_configuration["pool"]}"
  count = "${var.count}"
  size  = "${var.hana_disk_size}"
}

resource "libvirt_domain" "domain" {
  name       = "${var.base_configuration["name_prefix"]}${var.name}${var.count > 1 ? "-${count.index  + 1}" : ""}"
  memory     = "${var.memory}"
  vcpu       = "${var.vcpu}"
  running    = "${var.running}"
  count      = "${var.count}"
  qemu_agent = true

  // base disk + additional disks if any
  disk = ["${concat(
    list(
      map("volume_id", "${element(libvirt_volume.main_disk.*.id, count.index)}"),
      map("volume_id", "${element(libvirt_volume.hana_disk.*.id, count.index)}"),
    ),
    var.additional_disk
  )}"]

  network_interface = ["${list(
      map(
        "wait_for_lease", true,
        "network_name", var.base_configuration["network_name"],
        "bridge", var.base_configuration["bridge"],
        "mac", var.mac
      ),
      merge(
        map(
          "wait_for_lease", false,
          "network_id", var.base_configuration["isolated_network_id"],
          "hostname", "${var.name}${var.count > 1 ? "0${count.index  + 1}" : ""}"
        ),
        map("addresses", "${list(element(var.host_ips, count.index))}")
      )
    )}"]

  xml {
    xslt = "${file("modules/host/shareable.xsl")}"
  }

  connection {
    user     = "root"
    password = "linux"
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }

  cpu {
    mode = "host-passthrough"
  }

  provisioner "file" {
    source      = "../../salt"
    destination = "/root"
  }

  provisioner "file" {
    content = <<EOF

hostname: ${var.name}${var.count > 1 ? "0${count.index  + 1}" : ""}
domain: ${var.base_configuration["domain"]}
timezone: ${var.base_configuration["timezone"]}
reg_code: ${var.reg_code}
reg_email: ${var.reg_email}
reg_additional_modules: {${join(", ", formatlist("'%s': '%s'", keys(var.reg_additional_modules), values(var.reg_additional_modules)))}}
additional_repos: {${join(", ", formatlist("'%s': '%s'", keys(var.additional_repos), values(var.additional_repos)))}}
additional_packages: [${join(", ", formatlist("'%s'", var.additional_packages))}]
authorized_keys: [${trimspace(file(var.base_configuration["ssh_key_path"]))},${trimspace(file(var.ssh_key_path))}]
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
host_ip: ${element(var.host_ips, count.index)}

${var.grains}

EOF

    destination = "/etc/salt/grains"
  }

  provisioner "remote-exec" {
    inline = [
      "sh /root/salt/deployment.sh",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sh /root/salt/formula.sh",
    ]
  }
}

output "configuration" {
  value {
    id       = "${join(",", libvirt_domain.domain.*.id)}"
    hostname = "${join(",", libvirt_domain.domain.*.name)}"
  }
}

output "addresses" {
  // Returning only the addresses is not possible right now. Will be available in terraform 12
  // https://bradcod.es/post/terraform-conditional-outputs-in-modules/
  value = "${libvirt_domain.domain.*.network_interface}"
}
