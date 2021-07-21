#include "motor.h"

void Motor_Init() {
   // 小车的马达接在一个控制板上, 控制板接在STM32C8T6的USART2上. 控制马达要求使用半双工模式, usart.c中的MX_USART2_UART_Init()已经将USART2配置为半双工模式(HAL_HalfDuplex_Init)
   //   控制板       STM32C8T6
   //   5v            3.3v
   //   GND           GND
   //   RX            PA2(USART2_TX)
   //   TX            PA3(USART2_RX)
}
