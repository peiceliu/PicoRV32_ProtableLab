################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/main.c \
../src/uart.c 

S_UPPER_SRCS += \
../src/start.S 

OBJS += \
./src/main.o \
./src/start.o \
./src/uart.o 

S_UPPER_DEPS += \
./src/start.d 

C_DEPS += \
./src/main.d \
./src/uart.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: GNU RISC-V Cross C Compiler'
	riscv-none-embed-gcc -march=rv32imc -mabi=ilp32 -msmall-data-limit=8 -O2 -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -fno-common  -g -std=gnu11 -Wa,-adhlns="$@.lst" -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

src/%.o: ../src/%.S
	@echo 'Building file: $<'
	@echo 'Invoking: GNU RISC-V Cross Assembler'
	riscv-none-embed-gcc -march=rv32imc -mabi=ilp32 -msmall-data-limit=8 -O2 -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -fno-common  -g -x assembler-with-cpp -Wa,-adhlns="$@.lst" -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


