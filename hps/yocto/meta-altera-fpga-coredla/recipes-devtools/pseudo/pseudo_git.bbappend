# Bump pseudo to a revision that intercepts the openat2() syscall.
#
# Poky walnascar pins pseudo at 1.9.0+git (SRCREV 28dcefb), which predates
# openat2 support. On build hosts whose tar issues openat2() instead of
# openat() (any tar carrying the CVE-2025-45582 fix), pseudo never records the
# directory fd, so the tar copy in do_package fails with:
#   got *at() syscall for unknown directory, fd N
#   unknown base path for fd N, path ...
#   tar: ./usr/include: Cannot mkdir: Bad address
#
# pseudo 1.9.8, already carried by poky scarthgap, adds the openat2 wrapper and
# folds the glibc238 and PIE-flag fixes upstream, so those two patches are
# dropped here because they no longer apply to the newer source.
SRCREV = "823895ba708c63f6ae4dcbfc266210f26c02c698"
PV = "1.9.8"

SRC_URI:remove = "file://0001-configure-Prune-PIE-flags.patch file://glibc238.patch"

# walnascar's older-glibc-symbols.patch was written against the 1.9.0
# Makefile.in, which lacks pseudo_client_scanf.o, so it no longer applies.
# Prefer the rebased scarthgap copy shipped alongside this bbappend.
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
