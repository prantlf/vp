#ifndef RESOLVE_LINK_H
#define RESOLVE_LINK_H

#include <windef.h>

typedef struct _VP_REPARSE_DATA_BUFFER {
  ULONG  ReparseTag;
  USHORT ReparseDataLength;
  USHORT Reserved;
  // union {
  //   struct {
      USHORT SubstituteNameOffset;
      USHORT SubstituteNameLength;
      USHORT PrintNameOffset;
      USHORT PrintNameLength;
      ULONG  Flags;
      WCHAR  PathBuffer[1];
  //   } SymbolicLinkReparseBuffer;
  //   struct {
  //     USHORT SubstituteNameOffset;
  //     USHORT SubstituteNameLength;
  //     USHORT PrintNameOffset;
  //     USHORT PrintNameLength;
  //     WCHAR  PathBuffer[1];
  //   } MountPointReparseBuffer;
  //   struct {
  //     UCHAR DataBuffer[1];
  //   } GenericReparseBuffer;
  // } DUMMYUNIONNAME;
} VP_REPARSE_DATA_BUFFER, *PVP_REPARSE_DATA_BUFFER;

#endif
