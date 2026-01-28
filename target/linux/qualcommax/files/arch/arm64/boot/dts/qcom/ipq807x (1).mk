define Device/swaiot_cpe_s10
    $(call Device/FitImage)
    $(call Device/UbiFit)
    
    DEVICE_VENDOR := Swaiot
    DEVICE_MODEL := CPE-S10
    DEVICE_VARIANT := NAND
    SOC := ipq807x
    DEVICE_DTS := ipq8071-s10
    
    # NAND 参数
    BLOCKSIZE := 128k
    PAGESIZE := 2048
    KERNEL_IN_UBI := 1
    
    # 直接指定 FIT 构建命令，确保设备树被包含
    KERNEL = kernel-bin | gzip | fit gz $$(DTS_DIR)/$$(DEVICE_DTS).dtb
    KERNEL_NAME := zImage
    KERNEL_LOADADDR := 0x41000000
    KERNEL_ENTRY_POINT := 0x41000000
    
    IMAGE/sysupgrade.bin := sysupgrade-tar | append-metadata
endef
  
TARGET_DEVICES += swaiot_cpe_s10
