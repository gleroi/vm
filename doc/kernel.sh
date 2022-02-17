# build a basic kernel

DATA_DIR="${HOME}/vm/data"

KERNEL_URL="https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.16.10.tar.xz"
KERNEL_ARCHIVE="$(basename ${KERNEL_URL})"
KERNEL_NAME="$(basename -s .tar.xz ${KERNEL_URL})"

KERNEL_SRC_DIR="${DATA_DIR}/kernel/linux"
KERNEL_BUILD_DIR="${DATA_DIR}/kernel"

function clean() {
	rm -rf ${KERNEL_SRC_DIR}
}

function build() {
	pushd ${KERNEL_BUILD_DIR}
	if [ ! -f ${KERNEL_ARCHIVE} ]; then
		curl -O ${KERNEL_URL}
	fi
	tar --strip-components=1 -xf ${KERNEL_ARCHIVE} -C ${KERNEL_SRC_DIR}
	
	pushd ${KERNEL_SRC_DIR}
	make x86_64_defconfig
	make kvm_guest.config
	make -j8
	make dir-pkg
	mv tar-install ${KERNEL_BUILD_DIR}/${KERNEL_NAME}
	popd

	popd
}

mkdir -p $KERNEL_SRC_DIR
mkdir -p $KERNEL_BUILD_DIR

$*
