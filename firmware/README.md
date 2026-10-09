# Installer firmware

The files under `qcom/x1e80100/` were extracted from Jens Glathe's
`resolute-desktop-arm64+x1e-20260831_extended_jg.iso` initramfs.  They are
included because the installer DTB requests these generic X1E firmware names
and `qcom_q6v5_pas` must load them before the initrd mounts the installer ISO.

The exact 91B6 Purwa firmware names used by Jens's newer DTB are not present
in that public ISO, so these files are deliberately kept under the generic
paths currently used by this installer rather than being relabeled as 91B6
firmware.
