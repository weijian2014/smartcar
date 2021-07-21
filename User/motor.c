#include "motor.h"
#include "usart.h"

#define GET_LOW_BYTE(A) ((uint8_t)(A))
#define GET_HIGH_BYTE(A) ((uint8_t)((A) >> 8))

uint8_t checksum(uint8_t buf[]) {
   uint8_t  i;
   uint32_t sum = 0;
   for (i = 2; i < 8; i++) {
      sum += buf[i];
   }
   if (sum > 255)
      sum &= 0x00FF;
   return sum;
}

void Motor_RunS(uint8_t id, uint32_t rpm) {
   uint8_t buf[10];
   buf[0] = Motor_FRAME_HEADER1;
   buf[1] = Motor_FRAME_HEADER2;
   buf[2] = id;
   buf[3] = 0x01;
   buf[4] = Motor_RUNS;
   buf[5] = 0x00;
   buf[6] = GET_HIGH_BYTE(rpm);
   buf[7] = GET_LOW_BYTE(rpm);
   buf[8] = checksum(buf);
   buf[9] = Motor_FRAME_END;

   // HAL_HalfDuplex_EnableTransmitter(&huart2); // 为半双工模式要求每次发送和接收都需要使能相应的功能
   HAL_UART_Transmit(&huart2, buf, 10, 100);
}

void Motor_RunN(uint8_t id, uint32_t rpm) {
   uint8_t buf[10];
   buf[0] = Motor_FRAME_HEADER1;
   buf[1] = Motor_FRAME_HEADER2;
   buf[2] = id;
   buf[3] = 0x01;
   buf[4] = Motor_RUNN;
   buf[5] = 0x00;
   buf[6] = GET_HIGH_BYTE(rpm);
   buf[7] = GET_LOW_BYTE(rpm);
   buf[8] = checksum(buf);
   buf[9] = Motor_FRAME_END;

   // HAL_HalfDuplex_EnableTransmitter(&huart2); // 为半双工模式要求每次发送和接收都需要使能相应的功能
   HAL_UART_Transmit(&huart2, buf, 10, 100);
}

void Motor_Init() {
   // 小车的马达接在一个控制板上, 控制板接在STM32C8T6的USART2上. 控制马达要求使用半双工模式, usart.c中的MX_USART2_UART_Init()已经将USART2配置为半双工模式(HAL_HalfDuplex_Init)
   //   控制板       STM32C8T6
   //   5v            3.3v             可以不接VCC
   //   GND           GND              GND必须接!!!
   //   TX            PA2(USART2_TX)   控制板的TX和RX反了!!!必须这样接!!!
   //   RX            PA3(USART2_RX)

   Motor_RunN(1, 0); //电机1停止
   Motor_RunN(2, 0); //电机2停止
}
