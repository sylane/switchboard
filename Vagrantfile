# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
IP = "192.168.50.2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.ssh.forward_agent = true

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "provisioning/playbook.yml"
    ansible.groups = {"switchboard" => ["default"]}
    ansible.extra_vars = {"switchboard_host" => IP}
    ansible.skip_tags = ["clean"]

    # To run a subset of tasks, use e.g. TAGS="builder,switchboard" vagrant provision
    if ENV.has_key? "TAGS"
      ansible.tags = ENV["TAGS"].split ","
    end
  end

  config.vm.network "private_network", ip: IP
  config.vm.synced_folder ".", "/home/vagrant/switchboard"
end
