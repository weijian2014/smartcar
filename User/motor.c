#include "motor.h"
#include "usart.h"

#define GET_LOW_BYTE(A) ((uint8_t)(A))
#define GET_HIGH_BYTE(A) ((uint8_t)((A) >> 8))

void send(UART_HandleTypeDef* huart, uint8_t* pData, uint16_t Size, uint32_t Timeout) {
   // HAL_HalfDuplex_EnableTransmitter(&huart2); // 为半双工模式要求每次发送和接收都需要使能相应的功能
   HAL_UART_Transmit(huart, pData, Size, Timeout);
}

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
   uint8_t buf[10] = { Motor_FRAME_HEADER1, Motor_FRAME_HEADER2, id, 0x01, Motor_RUNS, 0x00, GET_HIGH_BYTE(rpm), GET_LOW_BYTE(rpm), checksum(buf), Motor_FRAME_END };
   send(&huart2, buf, 10, 100);
}

void Motor_RunN(uint8_t id, uint32_t rpm) {
   uint8_t buf[10] = { Motor_FRAME_HEADER1, Motor_FRAME_HEADER2, id, 0x01, Motor_RUNN, 0x00, GET_HIGH_BYTE(rpm), GET_LOW_BYTE(rpm), checksum(buf), Motor_FRAME_END };
   send(&huart2, buf, 10, 100);
}

uint32_t Motor_Speed(uint8_t id) {
   uint8_t buf[10] = { Motor_FRAME_HEADER1, Motor_FRAME_HEADER2, id, Motor_READ_ANGLE, 0x00, 0x00, 0x00, 0x00, checksum(buf), Motor_FRAME_END };
   send(&huart2, buf, 10, 100);

   uint8_t speed[16];
   speed[15] = '\0';
   if (HAL_OK != HAL_UART_Receive(&huart2, speed, 16, 100)) {
      printf("Read speed fail from id=[%d]\n", id);
   }
   else {
      printf("Read speed ok, id=[%d], speed=[%s]\n", id, speed);
   }
   return 0;
}

void Motor_Turnoff_Led(uint8_t id) {
   uint8_t buf[10] = { Motor_FRAME_HEADER1,
                       Motor_FRAME_HEADER2,
                       id,
                       Motor_LED,
                       0x01, // 0x01 LED灭, 0x00 LED亮
                       0x00,
                       0x00,
                       0x00,
                       checksum(buf),
                       Motor_FRAME_END };
   send(&huart2, buf, 10, 100);
}

void Motor_Init() {
   // 小车的马达接在一个控制板上, 控制板接在STM32C8T6的USART2上.
   // 控制马达要求使用半双工模式, usart.c中的MX_USART2_UART_Init()已经将USART2配置为半双工模式(HAL_HalfDuplex_Init)
   //   控制板       STM32C8T6
   //   5v            3.3v             可以不接VCC
   //   GND           GND              GND必须接!!!
   //   TX            PA2(USART2_TX)   控制板的TX和RX反了!!!必须这样接!!!
   //   RX            PA3(USART2_RX)

   Motor_Turnoff_Led(1);
   Motor_Turnoff_Led(2);

   Motor_RunN(1, 0); //电机1停止
   Motor_RunN(2, 0); //电机2停止
}
