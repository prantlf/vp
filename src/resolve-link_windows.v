import os { last_error }
import prantlf.debug { rwd }

#flag -I @VROOT/src
// #include <ntifs.h>
#include "resolve-link_win.h"
#include <winioctl.h>
#include <ioapiset.h>

fn C.CreateFileW(&u16, u32, u32, voidptr, u32, u32, voidptr) voidptr
fn C.CloseHandle(voidptr) C.BOOL
fn C.DeviceIoControl(voidptr, int, voidptr, int, voidptr, int, &int, voidptr) C.BOOL

@[typedef]
struct C.VP_REPARSE_DATA_BUFFER {
	ReparseTag        u32
	ReparseDataLength u16
	Reserved          u16
	// DUMMYUNIONNAME union {
	// 	SymbolicLinkReparseBuffer struct {
	SubstituteNameOffset u16
	SubstituteNameLength u16
	PrintNameOffset      u16
	PrintNameLength      u16
	Flags                u32
	PathBuffer           u16
	// 	}
	// 	MountPointReparseBuffer struct {
	// 		SubstituteNameOffset u16
	// 		SubstituteNameLength u16
	// 		PrintNameOffset u16
	// 		PrintNameLength u16
	// 		PathBuffer u16
	// 	}
	// 	GenericReparseBuffer struct {
	// 		DataBuffer u16
	// 	}
	// }
}

fn resolve_link(path string) !string {
	dpath := d.rwd(path)
	d.log('resolving the link "%s"', dpath)
	fh := C.CreateFileW(path.to_wide(), C.FILE_READ_EA, C.FILE_SHARE_READ | C.FILE_SHARE_WRITE | C.FILE_SHARE_DELETE,
		0, C.OPEN_EXISTING, C.FILE_FLAG_BACKUP_SEMANTICS | C.FILE_FLAG_OPEN_REPARSE_POINT,
		0)
	if fh == C.INVALID_HANDLE_VALUE {
		return error('opening link "${rwd(path)}" failed: ${last_error()}')
	}
	defer {
		C.CloseHandle(fh)
	}
	mut buf := []u8{len: C.MAXIMUM_REPARSE_DATA_BUFFER_SIZE}
	mut size := 0
	if C.DeviceIoControl(fh, C.FSCTL_GET_REPARSE_POINT, 0, 0, buf.data, buf.len, &size,
		0) != C.TRUE {
		return error('enquiring link "${rwd(path)}" failed: ${last_error()}')
	}
	data := unsafe { &C.VP_REPARSE_DATA_BUFFER(buf.data) }
	if data.ReparseTag != C.IO_REPARSE_TAG_SYMLINK {
		return error('"${rwd(path)}" is no symlink')
	}
	length := data.SubstituteNameLength / sizeof(u16)
	offset := data.SubstituteNameOffset / sizeof(u16)
	link_path := unsafe {
		string_from_wide2(&data.PathBuffer + offset, int(length))
	}
	dlink_path := d.rwd(link_path)
	d.log('resolved to "%s"', dlink_path)
	return link_path
}
