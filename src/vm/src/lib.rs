use syscalls::{Sysno, syscall, Errno};
use std::ffi::CString;

pub fn mount(source: &CString, target: &CString, fstype: &CString) -> Result<usize, Errno> {
    unsafe {
        syscall!(Sysno::mount, source.as_ptr(), target.as_ptr(), fstype.as_ptr(), 0, std::ptr::null() as *const i8)
    }
}
