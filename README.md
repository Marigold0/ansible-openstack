# Awalan
Sebelum menajalankan playbook konfigurasikan Basic Network pada semua node.
Minimal openstack membutuhkan 2 interface yang nantinya akan diatur untuk internal/management dan untuk provider/external.

NIC1 --> ens2 [192.168.100.86/24] *Dipakai Sebagai internal/management
		OpenVswitch[br-int]

NIC2 --> ens3/bond1 --> br-ex [172.31.250.19/22] *Dipakai sebagai provider/external


JIka kebutuhan prod disarankan menggunakan bond, agar bisa HA

Jika menggunakan OpenVswitch pada netplan
------------------------------------------
1. Install OpenVswitch
   | *sudo apt install openvswitch-switch openvswitch-common

2. Edit netplan dengan menabahkan "openvswitch:{}"
3. Samakan MAC Address bridge dengan interface fisik
   | *sudo ovs-vsctl set bridge br-ex other-config:hwaddr=fa:16:3e:47:f0:4b

4. Lalu restart openvswitch

KONFIGURASI NETPLAN
---------------------------------------------
Contoh netplan sederhana:

network:
  version: 2
  ethernets:
    ens3:
      match:
        macaddress: "fa:16:3e:74:ec:f9"
      dhcp4: true
      set-name: "ens3"
      mtu: 1442
    ens4:
      dhcp4: false
      mtu: 1500
  bridges:
    br-ex:
      interfaces: [ens4]
      addresses: 
        - 172.31.250.19/22
      routes:
        - to: default
          via: 172.31.248.1
      macaddress: "fa:16:3e:47:f0:4b"
      openvswitch: {}
      mtu: 1500
	  
# DEPLOY OPENSTACK AIO + CEPH
----------------------------------------------
1. copy pulic key nya dahulu
    ssh-copy-id user@hostname/ip

    ssh-copy-id init5@172.31.250.19
    
2. Edit File Inventory/host.ini

    [aio]
    { hostname } ansible_host={ internal ip } ansible_user={ user node target }
    optest2 ansible_host=172.31.250.19 ansible_user=init5

3. Untuk setting global ada pada file group_vars/all/vars.yml

4. Secret yang sudah di enkripsi ada di group_vars/all/vault.yml
    *Untuk edit*
    ansible-vault edit group_vars/all/vault.yml

    *Untuk membuat baru*
    ansible-vault create group_vars/all/namefile.yml

5. Untuk edit / setting aio ada pada groups_vars/aio/vars.yml
   Jangan lupa masukan nama disk yang akan dijadikan osd

6. Kemudian run playbook dengan *default pass adalah admin

    ansible-playbook -i inventory/host.ini aio.yml --ask-vault-pass

6. Akses horizon http://{ public_ip }/horizon
