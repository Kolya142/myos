@echo off
if exist os-image.img del os-image.img
nasm -f bin -o bootloader.bin bl.asm
nasm -f bin -o kernel.bin kernel.asm

fsutil file createnew os-image.img 20971520

"C:\utils\dd.exe" if=bootloader.bin of=os-image.img bs=512 count=1

"C:\utils\dd.exe" if=kernel.bin of=os-image.img bs=512 seek=1

rem "C:\utils\dd.exe" if=os.bin of=os-image.img bs=512 seek=1
