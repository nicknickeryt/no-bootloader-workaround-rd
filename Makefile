#
# Makefile
#
CC ?= gcc
LVGL_DIR_NAME ?= lvgl
LVGL_DIR ?= ${shell pwd}/utils/

WARNINGS ?= -Wall -Wextra \
						-Wshadow -Wundef -Wmaybe-uninitialized -Wmissing-prototypes -Wno-discarded-qualifiers \
						-Wno-unused-function -Wno-error=strict-prototypes -Wpointer-arith -fno-strict-aliasing -Wno-error=cpp -Wuninitialized \
						-Wno-unused-parameter -Wno-missing-field-initializers -Wno-format-nonliteral -Wno-cast-qual -Wunreachable-code -Wno-switch-default  \
					  -Wreturn-type -Wmultichar -Wformat-security -Wno-ignored-qualifiers -Wno-error=pedantic -Wno-sign-compare -Wno-error=missing-prototypes -Wdouble-promotion -Wclobbered -Wdeprecated  \
						-Wempty-body -Wshift-negative-value -Wstack-usage=2048 \
            -Wtype-limits -Wsizeof-pointer-memaccess -Wpointer-arith
            
CFLAGS ?= -O3 -g0 -I$(LVGL_DIR)/ $(WARNINGS) -static
LDFLAGS ?= -lm -lpthread -static
BIN = abm


#Collect the files to compile
MAINSRC = ./src/main.c

include gui/abm_gui.mk
include src/src.mk
include $(LVGL_DIR)/lvgl/lvgl.mk
include $(LVGL_DIR)/lv_drivers/lv_drivers.mk

OBJEXT ?= .o

AOBJS = $(ASRCS:.S=$(OBJEXT))
COBJS = $(CSRCS:.c=$(OBJEXT))

MAINOBJ = $(MAINSRC:.c=$(OBJEXT))

SRCS = $(ASRCS) $(CSRCS) $(MAINSRC)
OBJS = $(AOBJS) $(COBJS)

## MAINOBJ -> OBJFILES

all: rdcpiogz-generic rdcpiogz-vollaphone

%.o: %.c
	@$(CC)  $(CFLAGS) -c $< -o $@
	@echo "CC $<"
    

rd: abmbin
	@echo "Building ramdisk"
	@mkdir -p out/rd/bin
	@cp -P prebuilts/* out/rd/bin/
	@cp scripts/* out/rd/
	@cp abm out/rd/bin/
	
rdcpiogz-vollaphone: rd
	@cp devices/vollaphone/env.sh out/rd/env.sh
	@echo "Compressing rd with cpio"
	@(cd out/rd/ && find . | cpio -o -H newc | gzip > ../rd-yggdrasil.cpio.gz)
	
rdcpiogz-river: rd
	@cp devices/river/env.sh out/rd/env.sh
	@echo "Compressing rd with cpio"
	@(cd out/rd/ && find . | cpio -o -H newc | gzip > ../rd.cpio.gz)

rdcpiogz-generic: rd
	@echo "Compressing rd with cpio"
	@(cd out/rd/ && find . | cpio -o -H newc | gzip > ../rd.cpio.gz)

abmbin: $(AOBJS) $(COBJS) $(MAINOBJ)
	$(CC) -o $(BIN) $(MAINOBJ) $(AOBJS) $(COBJS) $(LDFLAGS)

clean: 
	rm -f $(BIN) $(AOBJS) $(COBJS) $(MAINOBJ) 
