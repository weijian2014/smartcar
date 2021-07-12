cmake_minimum_required(VERSION 3.13)

set(CMAKE_EXPORT_COMPILE_COMMANDS on)

set(STM32_TOOLCHAIN_PATH "D:/Program Files/stm32/GNU Arm Embedded Toolchain/10 2020-q4-major/bin")
set(CMAKE_TOOLCHAIN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/cmake/stm32_gcc.cmake")
set(STM32_CUBE_F1_PATH "C:/Users/weijian/STM32Cube/Repository/STM32Cube_FW_F1_V1.8.4")

# set(CMAKE_C_COMPILER "D:/Program Files/stm32/GNU Arm Embedded Toolchain/10 2020-q4-major/bin/arm-none-eabi-gcc.exe")
# set(CMAKE_ASM_COMPILER "D:/Program Files/stm32/GNU Arm Embedded Toolchain/10 2020-q4-major/bin/arm-none-eabi-gcc.exe")
# set(CMAKE_CXX_COMPILER "D:/Program Files/stm32/GNU Arm Embedded Toolchain/10 2020-q4-major/bin/arm-none-eabi-g++.exe")
set(CMAKE_OBJCOPY "D:/Program Files/stm32/GNU Arm Embedded Toolchain/10 2020-q4-major/bin/arm-none-eabi-objcopy.exe")
# set(CMAKE_OBJDUMP "D:/Program Files/stm32/GNU Arm Embedded Toolchain/10 2020-q4-major/bin/arm-none-eabi-objdump.exe")
set(CMAKE_SIZE "D:/Program Files/stm32/GNU Arm Embedded Toolchain/10 2020-q4-major/bin/arm-none-eabi-size.exe")
# set(CMAKE_DEBUGER "D:/Program Files/stm32/GNU Arm Embedded Toolchain/10 2020-q4-major/bin/arm-none-eabi-gdb.exe")
# set(CMAKE_CPPFILT "D:/Program Files/stm32/GNU Arm Embedded Toolchain/10 2020-q4-major/bin/arm-none-eabi-c++filt.exe")

set(CMAKE_VERBOSE_MAKEFILE ON)

# 只能放在这里！！不能前移
project(smartcar C ASM)

find_package(CMSIS COMPONENTS STM32F103C8 REQUIRED)

# list(APPEND CMSIS_COMP_LIST STM32F1)
# list(APPEND HAL_COMP_LIST STM32F1)
# find_package(CMSIS COMPONENTS "${CMSIS_COMP_LIST}" REQUIRED)
# find_package(HAL COMPONENTS "${HAL_COMP_LIST}" REQUIRED)

add_definitions(
   -DUSE_HAL_DRIVER
   -DSTM32F103xB
   # -u_printf_float   # 可以使用printf("%f"), 经测试不加也可以输入
   # -u_sprintf_float  # 可以使用sprintf("%f"), 经测试不加也可以输入
)

include_directories(
   Inc
   Drivers/STM32F1xx_HAL_Driver/Inc
   Drivers/STM32F1xx_HAL_Driver/Inc/Legacy
   Drivers/CMSIS/Device/ST/STM32F1xx/Include
   Drivers/CMSIS/Include
)

add_executable(smartcar
   Src/main.c
   Src/gpio.c
   Src/i2c.c
   Src/usart.c
   Src/stm32f1xx_it.c
   Src/stm32f1xx_hal_msp.c
   Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_gpio_ex.c
   Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_i2c.c
   Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_uart.c
   Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal.c
   Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_rcc.c
   Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_rcc_ex.c
   Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_gpio.c
   Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_dma.c
   Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_cortex.c
   Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_pwr.c
   Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_flash.c
   Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_flash_ex.c
   Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_exti.c
   Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_tim.c
   Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_tim_ex.c
   # Src/system_stm32f1xx.c 这个不需要, 否则编译提示符号重复定义
   # startup_stm32f103xb.s  这个不需要, find_package(CMSIS)时自动找到STM32_CUBE_F1_PATH目录下的Drivers\CMSIS\Device\ST\STM32F1xx\Source\Templates\gcc\startup_stm32f103xb.s
)
target_link_libraries(smartcar
   CMSIS::STM32::F103C8
   STM32::NoSys
)
# stm32_add_linker_script(smartcar STM32F103C8Tx_FLASH.ld)
# set(CMAKE_EXE_LINKER_FLAGS "-specs=nano.specs -T${PROJECT_SOURCE_DIR}/STM32F103C8Tx_FLASH.ld -Wl,-Map=${PROJECT_BINARY_DIR}/smartcar.map,--cref -Wl,--gc-sections")

# 将elf文件转hex和bin
add_custom_command(
    TARGET smartcar
    POST_BUILD COMMAND ${CMAKE_OBJCOPY} -O ihex smartcar.elf smartcar.hex
    POST_BUILD COMMAND ${CMAKE_OBJCOPY} -O binary smartcar.elf smartcar.bin
)

# 显示代码段大小
add_custom_command(
   TARGET smartcar
   POST_BUILD COMMAND ${CMAKE_SIZE} smartcar.elf
)

add_custom_command(
   TARGET smartcar
   POST_BUILD COMMAND ${CMAKE_SIZE} smartcar.hex
)

# smartcar.bin会报一个错误
# add_custom_command(
#    TARGET smartcar
#    POST_BUILD COMMAND ${CMAKE_SIZE} smartcar.bin
# )
