use std::ffi::CString;
use std::error::Error;
use vm::mount;


fn main() -> Result<(), Box<dyn Error>>{
    let file = CString::new("/tmp/img.raw")?;
    let mount_point = CString::new("/mnt/root")?;
    let fs_type = CString::new("ext4")?;

    let _ok = mount(&file, &mount_point, &fs_type)?;
    Ok(())
}
