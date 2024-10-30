################################################################################
# Automatically-generated file. Do not edit!
################################################################################

-include ../makefile.init

RM := rm -rf

# All of the sources participating in the build are defined here
-include sources.mk
-include src/subdir.mk
-include subdir.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(ASM_DEPS)),)
-include $(ASM_DEPS)
endif
ifneq ($(strip $(S_UPPER_DEPS)),)
-include $(S_UPPER_DEPS)
endif
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
endif

-include ../makefile.defs

# Add inputs and outputs from these tool invocations to the build variables 
SECONDARY_FLASH += \
pico_test_1.bin \

SECONDARY_LIST += \
pico_test_1.lst \

SECONDARY_SIZE += \
pico_test_1.siz \


# All Target
all: pico_test_1.elf secondary-outputs

# Tool invocations
pico_test_1.elf: $(OBJS) $(USER_OBJS)
	@echo 'Building target: $@'
	@echo 'Invoking: GNU RISC-V Cross C Linker'
	riscv-none-embed-gcc -march=rv32imc -mabi=ilp32 -msmall-data-limit=8 -O2 -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -fno-common  -g -T "D:\Hummingbird\HBird-workspace\pico_test_1\src\sections.lds" -nostartfiles -Wl,-Map,"pico_test_1.map" -mcmodel=medlow -o "pico_test_1.elf" $(OBJS) $(USER_OBJS) $(LIBS)
	@echo 'Finished building target: $@'
	@echo ' '

pico_test_1.bin: pico_test_1.elf
	@echo 'Invoking: GNU RISC-V Cross Create Flash Image'
	riscv-none-embed-objcopy -O binary -j .text -j .data "pico_test_1.elf"  "pico_test_1.bin"
	@echo 'Finished building: $@'
	@echo ' '

pico_test_1.lst: pico_test_1.elf
	@echo 'Invoking: GNU RISC-V Cross Create Listing'
	riscv-none-embed-objdump --source --all-headers --demangle --line-numbers --wide "pico_test_1.elf" > "pico_test_1.lst"
	@echo 'Finished building: $@'
	@echo ' '

pico_test_1.siz: pico_test_1.elf
	@echo 'Invoking: GNU RISC-V Cross Print Size'
	riscv-none-embed-size --format=berkeley "pico_test_1.elf"
	@echo 'Finished building: $@'
	@echo ' '

# Other Targets
clean:
	-$(RM) $(OBJS)$(SECONDARY_FLASH)$(SECONDARY_LIST)$(SECONDARY_SIZE)$(ASM_DEPS)$(S_UPPER_DEPS)$(C_DEPS) pico_test_1.elf
	-@echo ' '

secondary-outputs: $(SECONDARY_FLASH) $(SECONDARY_LIST) $(SECONDARY_SIZE)

.PHONY: all clean dependents

-include ../makefile.targets
