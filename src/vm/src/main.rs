use libc;
use std::ffi::CString;
use std::error::Error;

fn errno() -> i32 {
    use libc::__errno_location;
    unsafe {
        let ptr = __errno_location();
        return *ptr;
    }
}

fn main() -> Result<(), Box<dyn Error>>{
    let file = CString::new("/tmp/img.raw")?;
    let mount_point = CString::new("/mnt/root")?;
    let fs_type = CString::new("ext4")?;

    let result = unsafe {
        let res = libc::mount(file.as_ptr(), mount_point.as_ptr(), fs_type.as_ptr(), 0, std::ptr::null());
        if res < 0 {
            Err(std::io::Error::last_os_error())
        } else {
            Ok(res)
        }
    };
    println!("mount result is : {:?}", result);
    Ok(())
}
