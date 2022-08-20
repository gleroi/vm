# create a exherbo img

set -x

DATA_DIR="${HOME}/vm/data"
IMG_DIR="${HOME}/vm/data/imgs"
mkdir -p ${IMG_DIR}

function clean() {
	rm -rf ${IMG_RAW_PATH}
	rm -rf ${IMG_COW_PATH}
  rm -f ${DATA_DIR}/${EXHERBO_ARCHIVE}
}

# img

IMG_HOST_MOUNTPOINT="/mnt/root"
IMG_RAW_PATH="${IMG_DIR}/exherbo_base.raw"
IMG_COW_PATH="${IMG_DIR}/exherbo_base.qcow2"

EXHERBO_URL="https://dev.exherbo.org/stages/exherbo-x86_64-pc-linux-gnu-current.tar.xz"
EXHERBO_ARCHIVE="$(basename ${EXHERBO_URL})"

function build() {
	qemu-img create -f raw ${IMG_RAW_PATH} 4G
	mkfs.ext4 ${IMG_RAW_PATH}

  sudo mkdir -p ${IMG_HOST_MOUNTPOINT}
	sudo mount ${IMG_RAW_PATH} ${IMG_HOST_MOUNTPOINT}

  pushd ${DATA_DIR}
    if [ ! -f ${EXHERBO_ARCHIVE} ]; then
      curl -OL ${EXHERBO_URL}
    fi
  popd

  sudo tar -xJpf ${DATA_DIR}/${EXHERBO_ARCHIVE} -C ${IMG_HOST_MOUNTPOINT}
  sudo cp /etc/resolv.conf ${IMG_HOST_MOUNTPOINT}/etc/resolv.conf

  sudo cp setup.sh ${IMG_HOST_MOUNTPOINT}/root/setup.sh
	sudo arch-chroot ${IMG_HOST_MOUNTPOINT} bash /root/setup.sh
	
  sudo umount ${IMG_HOST_MOUNTPOINT}

	qemu-img convert -f raw -O qcow2 ${IMG_RAW_PATH} ${IMG_COW_PATH}
}

INSTANCE_DIR="${DATA_DIR}/instances"
mkdir -p ${INSTANCE_DIR}

INSTANCE_COW_PATH="${INSTANCE_DIR}/arch_instance.qcow2"

KERNEL_BUILD_DIR="${DATA_DIR}/kernel"
KERNEL_NAME="linux-5.19.1"
KERNEL_PATH="${KERNEL_BUILD_DIR}/${KERNEL_NAME}/boot/vmlinuz-5.19.1"

function run() {
	rm -f ${INSTANCE_COW_PATH}
	qemu-img create -F qcow2 -b ${IMG_COW_PATH} -f qcow2 ${INSTANCE_COW_PATH}
	qemu-system-x86_64 -hda ${INSTANCE_COW_PATH} \
		-kernel ${KERNEL_PATH} \
		-append "root=/dev/sda rw console=ttyS0 loglevel=1" \
		-m 4G \
		-nographic \
		--enable-kvm
}
echo "EXHERBO: do $*"
$*
