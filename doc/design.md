# VM: design doc

## setup
qemu

## config

- **data-dir** : folder containing vm data
  - run: running/suspended vms disks
	- 

## commands

vm create
- try to use virtio for disk and net

vm start
vm stop

vm network
- create private network to attach vms together
- open network to internet or not

vm disk
- create disk
- attach them

vm image
- create image from iso
- create image from packer/vagrant/
- create image from docker ?

