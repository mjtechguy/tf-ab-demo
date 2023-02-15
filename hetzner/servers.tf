resource "hcloud_ssh_key" "hcloud_ssh_key" {
    name = "${var.deployment_name}_ssh_key"
    public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "hcloud_server" "hcloud_demo_server" {
    count = 1
    name = "${var.deployment_name}-server-${count.index}"
    image = "ubuntu-20.04"
    server_type = "cpx21"
    location = "ash"
    ssh_keys = [hcloud_ssh_key.hcloud_ssh_key.id]
    labels = {
        type = "demo"
    }
}

