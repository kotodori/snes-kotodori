CL65 = cl65
LD65 = ld65

ROM_NAME := snes_kotodori.smc
CONFIG := snes_kotodori.cfg
SOURCE_DIR := src
OUT_DIR := build

TARGET := $(OUT_DIR)/$(ROM_NAME)
SOURCES := $(shell find $(SOURCE_DIR) -name "*.asm")
OBJECTS := $(addprefix $(OUT_DIR)/,$(patsubst %.asm,%.o,$(SOURCES)))

.PHONY: all clean
all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(LD65) -o $@ --config $(CONFIG) --obj $^

$(OUT_DIR)/%.o: %.asm
	@if [ ! -e `dirname $@` ]; then mkdir -p `dirname $@`; fi
	$(CL65) -t none -o $@ -c $<

clean:
	rm -rf $(OUT_DIR)
