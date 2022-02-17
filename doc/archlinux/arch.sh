# create a archlinux img
#
# pacman requirements:
# - arch-install-scripts
# - qemu

DATA_DIR="${HOME}/vm/data"
IMG_DIR="${HOME}/vm/data/imgs"
mkdir -p ${IMG_DIR}

function clean() {
	rm -rf ${IMG_RAW_PATH}
	rm -rf ${IMG_COW_PATH}
}

# img

IMG_HOST_MOUNTPOINT="/mnt/root"
IMG_RAW_PATH="${IMG_DIR}/archlinux_base.raw"
IMG_COW_PATH="${IMG_DIR}/archlinux_base.qcow2"

function build() {
	qemu-img create -f raw ${IMG_RAW_PATH} 4G
	mkfs.ext4 ${IMG_RAW_PATH}

	sudo mount ${IMG_RAW_PATH} ${IMG_HOST_MOUNTPOINT}
	sudo pacstrap ${IMG_HOST_MOUNTPOINT} base
	cat > ${IMG_DIR}/setup.sh <<EOF
passwd --delete root
rm -f /root/setup.sh
EOF
	sudo cp ${IMG_DIR}/setup.sh ${IMG_HOST_MOUNTPOINT}/root/setup.sh
	sudo arch-chroot ${IMG_HOST_MOUNTPOINT} bash /root/setup.sh
	sudo umount ${IMG_HOST_MOUNTPOINT}

	qemu-img convert -f raw -O qcow2 ${IMG_RAW_PATH} ${IMG_COW_PATH}
}

INSTANCE_DIR="${DATA_DIR}/instances"
mkdir -p ${INSTANCE_DIR}

INSTANCE_COW_PATH="${INSTANCE_DIR}/arch_instance.qcow2"

KERNEL_BUILD_DIR="${DATA_DIR}/kernel"
KERNEL_NAME="linux-5.16.10"
KERNEL_PATH="${KERNEL_BUILD_DIR}/${KERNEL_NAME}/boot/vmlinuz-5.16.10"

function run() {
	rm -f ${INSTANCE_COW_PATH}
	qemu-img create -F qcow2 -b ${IMG_COW_PATH} -f qcow2 ${INSTANCE_COW_PATH}
	qemu-system-x86_64 -hda ${INSTANCE_COW_PATH} \
		-kernel ${KERNEL_PATH} \
		-append "root=/dev/sda rw console=ttyS0 loglevel=5" \
		-m 4G \
		-nographic \
		--enable-kvm
}

echo "ARCH: do $*"
$*
