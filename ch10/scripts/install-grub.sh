#!/bin/bash
set -eu

. /sources/.lfsenv || {
  echo "❌ Could not load LFS environment."
  exit 1
}

if [ "$LFS_PARTITION_SCHEME" = "gpt" ]; then
  echo "👉 Installing GRUB for UEFI..."
  
  mkdir -pv /boot/efi
  mount -v -t vfat "$LFS_BOOT" /boot/efi

  grub-install --target=x86_64-efi \
               --bootloader-id=LFS \
               --efi-directory=/boot/efi \
               --boot-directory=/boot \
               --recheck

else
  echo "👉 Installing GRUB for BIOS/MBR..."
  grub-install "$LFS_BOOT" --target=i386-pc
fi

cat > /boot/grub/grub.cfg << EOF
# Begin /boot/grub/grub.cfg
set default=0
set timeout=5

insmod part_${LFS_PARTITION_SCHEME}
insmod ext2
set root=(hd0,1)

EOF

if [ "$LFS_PARTITION_SCHEME" = "gpt" ]; then
  cat >> /boot/grub/grub.cfg << "EOF"
insmod efi_gop
insmod efi_uga
if loadfont /boot/grub/fonts/unicode.pf2; then
  terminal_output gfxterm
fi
EOF
fi

cat >> /boot/grub/grub.cfg << "EOF"

menuentry "GNU/Linux, Linux 6.13.4-lfs-12.3" {
  linux /boot/vmlinuz-6.13.4-lfs-12.3 root=${LFS_ROOT} ro
}

menuentry "Firmware Setup" {
  fwsetup
}
EOF

