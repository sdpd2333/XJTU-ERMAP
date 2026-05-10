################################################################################
# Automatically-generated file. Do not edit!
################################################################################

SHELL = cmd.exe

CG_TOOL_ROOT := C:/ti/ccs1281/ccs/tools/compiler/ti-cgt-arm_20.2.7.LTS

GEN_OPTS__FLAG := 
GEN_CMDS__FLAG := 

ORDERED_OBJS += \
"./gpio_if.obj" \
"./main.obj" \
"./pinmux.obj" \
"./startup_ccs.obj" \
"../cc3200v1p32.cmd" \
$(GEN_CMDS__FLAG) \
-l"C:/ti/CC3200SDK_1.5.0/cc3200-sdk/driverlib/ccs/Release/driverlib.a" \
-llibc.a \

-include ../makefile.init

RM := DEL /F
RMDIR := RMDIR /S/Q

# All of the sources participating in the build are defined here
-include sources.mk
-include subdir_vars.mk
-include subdir_rules.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(C55_DEPS)),)
-include $(C55_DEPS)
endif
ifneq ($(strip $(C_UPPER_DEPS)),)
-include $(C_UPPER_DEPS)
endif
ifneq ($(strip $(S67_DEPS)),)
-include $(S67_DEPS)
endif
ifneq ($(strip $(S62_DEPS)),)
-include $(S62_DEPS)
endif
ifneq ($(strip $(S_DEPS)),)
-include $(S_DEPS)
endif
ifneq ($(strip $(OPT_DEPS)),)
-include $(OPT_DEPS)
endif
ifneq ($(strip $(C??_DEPS)),)
-include $(C??_DEPS)
endif
ifneq ($(strip $(ASM_UPPER_DEPS)),)
-include $(ASM_UPPER_DEPS)
endif
ifneq ($(strip $(S??_DEPS)),)
-include $(S??_DEPS)
endif
ifneq ($(strip $(C64_DEPS)),)
-include $(C64_DEPS)
endif
ifneq ($(strip $(CXX_DEPS)),)
-include $(CXX_DEPS)
endif
ifneq ($(strip $(S64_DEPS)),)
-include $(S64_DEPS)
endif
ifneq ($(strip $(INO_DEPS)),)
-include $(INO_DEPS)
endif
ifneq ($(strip $(CLA_DEPS)),)
-include $(CLA_DEPS)
endif
ifneq ($(strip $(S55_DEPS)),)
-include $(S55_DEPS)
endif
ifneq ($(strip $(SV7A_DEPS)),)
-include $(SV7A_DEPS)
endif
ifneq ($(strip $(C62_DEPS)),)
-include $(C62_DEPS)
endif
ifneq ($(strip $(C67_DEPS)),)
-include $(C67_DEPS)
endif
ifneq ($(strip $(PDE_DEPS)),)
-include $(PDE_DEPS)
endif
ifneq ($(strip $(K_DEPS)),)
-include $(K_DEPS)
endif
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
ifneq ($(strip $(CC_DEPS)),)
-include $(CC_DEPS)
endif
ifneq ($(strip $(C++_DEPS)),)
-include $(C++_DEPS)
endif
ifneq ($(strip $(C43_DEPS)),)
-include $(C43_DEPS)
endif
ifneq ($(strip $(S43_DEPS)),)
-include $(S43_DEPS)
endif
ifneq ($(strip $(ASM_DEPS)),)
-include $(ASM_DEPS)
endif
ifneq ($(strip $(S_UPPER_DEPS)),)
-include $(S_UPPER_DEPS)
endif
ifneq ($(strip $(CPP_DEPS)),)
-include $(CPP_DEPS)
endif
ifneq ($(strip $(SA_DEPS)),)
-include $(SA_DEPS)
endif
endif

-include ../makefile.defs

# Add inputs and outputs from these tool invocations to the build variables 
EXE_OUTPUTS += \
blinky.out 

EXE_OUTPUTS__QUOTED += \
"blinky.out" 


# All Target
all: $(OBJS) $(CMD_SRCS) $(GEN_CMDS)
	@$(MAKE) --no-print-directory -Onone "blinky.out"

# Tool invocations
blinky.out: $(OBJS) $(CMD_SRCS) $(GEN_CMDS)
	@echo 'Building target: "$@"'
	@echo 'Invoking: Arm Linker'
	"C:/ti/ccs1281/ccs/tools/compiler/ti-cgt-arm_20.2.7.LTS/bin/armcl" -mv7M4 --code_state=16 --float_support=none -me -Ooff --define=ccs --define=cc3200 --define=NON_NETWORK -g --diag_warning=225 --diag_wrap=off --display_error_number --abi=eabi -z -m"blinky.map" --heap_size=0x800 --stack_size=0x800 -i"C:/ti/ccs1281/ccs/tools/compiler/ti-cgt-arm_20.2.7.LTS/lib" -i"C:/ti/ccs1281/ccs/tools/compiler/ti-cgt-arm_20.2.7.LTS/include" --reread_libs --diag_wrap=off --display_error_number --warn_sections --xml_link_info="blinky_linkInfo.xml" --rom_model -o "blinky.out" $(ORDERED_OBJS)
	@echo 'Finished building target: "$@"'
	@echo ' '
	@$(MAKE) --no-print-directory post-build

# Other Targets
clean:
	-$(RM) $(EXE_OUTPUTS__QUOTED)
	-$(RM) "gpio_if.obj" "main.obj" "pinmux.obj" "startup_ccs.obj" 
	-$(RM) "gpio_if.d" "main.d" "pinmux.d" "startup_ccs.d" 
	-@echo 'Finished clean'
	-@echo ' '

post-build:
	-C:/ti/ccs1281/ccs/utils/tiobj2bin/tiobj2bin blinky.out blinky.bin C:/ti/ccs1281/ccs/tools/compiler/ti-cgt-arm_20.2.7.LTS/bin/armofd C:/ti/ccs1281/ccs/tools/compiler/ti-cgt-arm_20.2.7.LTS/bin/armhex C:/ti/ccs1281/ccs/utils/tiobj2bin/mkhex4bin
	-@echo ' '

.PHONY: all clean dependents
.SECONDARY:

-include ../makefile.targets

