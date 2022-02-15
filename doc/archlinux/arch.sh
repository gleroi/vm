# create a archlinux img
#
# pacman requirements:
# - arch-install-scripts
# - qemu

DATA_DIR="${HOME}/vm/data"
mkdir -p ${DATA_DIR}

function cleanup() {
	rm -rf ${IMG_RAW_PATH}
	rm -rf ${IMG_COW_PATH}
}

# img

IMG_HOST_MOUNTPOINT="/mnt/root"
IMG_RAW_PATH="${DATA_DIR}/archlinux_base.raw"
IMG_COW_PATH="${DATA_DIR}/archlinux_base.qcow2"

function build() {
	qemu-img create -f raw ${IMG_RAW_PATH} 4G
	mkfs.ext4 ${IMG_RAW_PATH}

	sudo mount ${IMG_RAW_PATH} ${IMG_HOST_MOUNTPOINT}
	sudo pacstrap ${IMG_HOST_MOUNTPOINT} base
	sudo umount ${IMG_HOST_MOUNTPOINT}

	qemu-img convert -f raw -O qcow2 ${IMG_RAW_PATH} ${IMG_COW_PATH}
}

RUN_DIR="${HOME}/vm/data/run"
mkdir -p ${RUN_DIR}

INSTANCE_IMG_PATH="${RUN_DIR}/arch_instance.qcow2"

function run() {
#	qemu-img create -F qcow2 -b ${IMG_COW_PATH} -f qcow2 ${INSTANCE_IMG_PATH} 20M
	qemu-system-x86_64 -hda ${IMG_RAW_PATH} \
		-m 4G \
		-nographic \
		-kernel /boot/vmlinuz-linux \
		-append "root=/dev/sda rw console=ttyS0 loglevel=5" \
		--enable-kvm
}

echo "ARCH: do $*"
$*
