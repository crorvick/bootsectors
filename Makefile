
%.bin: %.o
	objcopy -O binary -j .text $< $@

all: msdos-mbr.bin winxp-bs.bin

clean:
	rm -f *.o
	rm -f *.bin
