DEVICE_VARS += NETGEAR_BOARD_ID NETGEAR_HW_ID TPLINK_SUPPORT_STRING

define Build/asus-fake-ramdisk
	rm -rf $(KDIR)/tmp/fakerd
	dd if=/dev/zero bs=32 count=1 > $(KDIR)/tmp/fakerd
	$(info KERNEL_INITRAMFS is $(KERNEL_INITRAMFS))
endef

define Build/asus-fake-rootfs
	$(eval comp=$(word 1,$(1)))
	$(eval filepath=$(word 2,$(1)))
	$(eval filecont=$(word 3,$(1)))
	rm -rf $(KDIR)/tmp/fakefs $(KDIR)/tmp/fakehsqs
	mkdir -p $(KDIR)/tmp/fakefs/$$(dirname $(filepath))
	echo '$(filecont)' > $(KDIR)/tmp/fakefs/$(filepath)
	$(STAGING_DIR_HOST)/bin/mksquashfs4 $(KDIR)/tmp/fakefs $(KDIR)/tmp/fakehsqs -comp $(comp) \
		-b 4096 -no-exports -no-sparse -no-xattrs -all-root -noappend \
		$(wordlist 4,$(words $(1)),$(1))
endef

define Build/asus-trx
	$(STAGING_DIR_HOST)/bin/asusuimage $(wordlist 1,$(words $(1)),$(1)) -i $@ -o $@.new
	mv $@.new $@
endef

define Build/wax6xx-netgear-tar
	mkdir $@.tmp
	mv $@ $@.tmp/nand-ipq807x-apps.img
	md5sum $@.tmp/nand-ipq807x-apps.img | cut -c 1-32 > $@.tmp/nand-ipq807x-apps.md5sum
	echo $(DEVICE_MODEL) > $@.tmp/metadata.txt
	echo $(DEVICE_MODEL)"_V99.9.9.9" > $@.tmp/version
	tar -C $@.tmp/ -cf $@ .
	rm -rf $@.tmp
endef

define Build/zyxel-nwa210ax-fit
	$(TOPDIR)/scripts/mkits-zyxel-fit-filogic.sh \
		$@.its $@ "5c e1 ff ff ff ff ff ff ff ff"
	PATH=$(LINUX_DIR)/scripts/dtc:$(PATH) mkimage -f $@.its $@.new
	@mv $@.new $@
endef

define Device/swaiot_cpe_s10
  $(call Device/UbiFit)
  
  DEVICE_VENDOR := Swaiot
  DEVICE_MODEL := CPE-S10
  DEVICE_VARIANT := NAND
  SOC := ipq8071
  DEVICE_DTS := ipq8071-s10
  
  # NAND 参数
  BLOCKSIZE := 128k
  PAGESIZE := 2048
  KERNEL_IN_UBI := 1
  
  # 内核配置
  KERNEL = kernel-bin | lzma | fit lzma $$(DTS_DIR)/$$(DEVICE_DTS).dtb
  KERNEL_NAME := Image
  KERNEL_LOADADDR := 0x41000000
  KERNEL_ENTRY_POINT := 0x41000000
  
  # UBI 配置（根据实际分区大小调整）
  IMAGE_SIZE := 110592k  # 108MB
  KERNEL_SIZE := 16384k  # 16MB
  
  IMAGE/sysupgrade.bin := sysupgrade-ubi | append-metadata
endef

TARGET_DEVICES += swaiot_cpe_s10


define Device/aliyun_ap8220
	$(call Device/FitImage)
	$(call Device/UbiFit)
	DEVICE_VENDOR := Aliyun
	DEVICE_MODEL := AP8220
	BLOCKSIZE := 128k
	PAGESIZE := 2048
	SOC := ipq8071
	DEVICE_DTS_CONFIG := config@ac02
	DEVICE_PACKAGES := ipq-wifi-aliyun_ap8220 kmod-hci-uart kmod-bluetooth kmod-bluetooth-6lowpan
endef
TARGET_DEVICES += aliyun_ap8220

define Device/arcadyan_aw1000
	$(call Device/FitImage)
	$(call Device/UbiFit)
	DEVICE_VENDOR := Arcadyan
	DEVICE_MODEL := AW1000
	BLOCKSIZE := 256k
	PAGESIZE := 4096
	SOC := ipq8072
	DEVICE_DTS_CONFIG := config@hk09
	DEVICE_PACKAGES := ipq-wifi-arcadyan_aw1000 kmod-gpio-nxp-74hc164 kmod-usb-serial-option uqmi
endef
TARGET_DEVICES += arcadyan_aw1000
