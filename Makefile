
GPPPARAMS = -m32 -fno-use-cxa-atexit -nostdlib -fno-builtin -fno-rtti -fno-exceptions -fno-leading-underscore
ASPARAMS = --32
LDPARAMS = -melf_i386


objects = loader.o kernel.o


%.o: %.cpp
	g++ $(GPPPARAMS) -o $@ -c $<
	
%.o: %.s
	as $(ASPARAMS) -o $@ $<
	
mykernel.bin: linker.ld $(objects)
	ld $(LDPARAMS) -T $< -o $@ $(objects)

install: mykernel.bin
	sudo cp $< /boot/mykernel.bin
	
	
mykernel.iso: mykernel.bin
	mkdir iso
	mkdir iso/boot
	cp $< iso/boot
	echo 'set timeout=0' >> iso/boot/grub.cfg
	echo 'set default=0' >> iso/boot/grub.cfg
	echo '' >> iso/boot/grub.cfg
	echo '	menuentry "KernelBoot" {' >> iso/boot/grub.cfg
	echo '	multiboot /boot/mykernel.bin' >> iso/boot/grub.cfg
	echo '	boot' >> iso/boot/grub.cfg
	echo '}' >> iso/boot/grub.cfg
	grub-mkrescue --output $@ iso
	rm -rf iso
	
run:  mykernel.iso
	(killall VirtualBox && sleep 1) || true
	VirtualBox --startvm "KernelBoot" &
	
