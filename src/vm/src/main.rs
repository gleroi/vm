use syscalls::{Sysno, syscall, Errno};
use std::ffi::CString;
use std::error::Error;

fn mount(source: &CString, target: &CString, fstype: &CString) -> Result<usize, Errno> {
    unsafe {
        syscall!(Sysno::mount, source.as_ptr(), target.as_ptr(), fstype.as_ptr(), 0, std::ptr::null() as *const i8)
    }
}

fn main() -> Result<(), Box<dyn Error>>{
    let file = CString::new("/tmp/img.raw")?;
    let mount_point = CString::new("/mnt/root")?;
    let fs_type = CString::new("ext4")?;

    let _ok = mount(&file, &mount_point, &fs_type)?;
    Ok(())
}
