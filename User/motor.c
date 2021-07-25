#include "motor.h"
#include "stdio.h"
#include "usart.h"

struct MotorConfigulation MotorConfig;

#define Max_Speed_Level 10
#define Min_Speed_Level 1

uint16_t Speed_Rpm[Max_Speed_Level] = { 200, 400, 600, 800, 1000, 1200, 1400, 1600, 1800, 2000 };

#define Motor_Buf_Max_Len 10
uint8_t Motor_Recv_Buf[Motor_Buf_Max_Len];

void send(uint8_t* pData, uint16_t Size) {
   HAL_UART_Transmit(&huart2, pData, Size, MotorConfig.sendRecvTimeout);
}

void printfRecvBuf(uint8_t id, char* prefix) {
   printf("%s, id=[%d], buf=[%02X, %02X, %02X, %02X, %02X, %02X, %02X, %02X, %02X, %02X]\n", prefix, id, Motor_Recv_Buf[0], Motor_Recv_Buf[1], Motor_Recv_Buf[2], Motor_Recv_Buf[3], Motor_Recv_Buf[4],
          Motor_Recv_Buf[5], Motor_Recv_Buf[6], Motor_Recv_Buf[7], Motor_Recv_Buf[8], Motor_Recv_Buf[9]);
}

void parseSpeed(uint8_t id) {
   if (Motor_FRAME_HEADER1 != Motor_Recv_Buf[0] || Motor_FRAME_HEADER2 != Motor_Recv_Buf[1] || Motor_FRAME_END != Motor_Recv_Buf[9]) {
      printfRecvBuf(id, "parseSpeed, get speed fail");
      return;
   }
   uint16_t targetSpeed = (uint16_t)Motor_Recv_Buf[4] + (uint16_t)Motor_Recv_Buf[5];
   uint16_t realSpeed   = (uint16_t)Motor_Recv_Buf[6] + (uint16_t)Motor_Recv_Buf[7];
   printf("parseSpeed, id=[%d], targetSpeed=[%d], realSpeed=[%d]\n", id, targetSpeed, realSpeed);
}

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
   uint8_t buf[10] = { Motor_FRAME_HEADER1, Motor_FRAME_HEADER2, id, 0x01, Motor_RUNS, 0x00, GET_HIGH_BYTE(rpm), GET_LOW_BYTE(rpm), checksum(buf), Motor_FRAME_END };
   send(buf, 10);

   if (!MotorConfig.isGetSpeed) {
      return;
   }

   // 返回 0XAA+id（只返回1个字节）
   HAL_UART_Receive(&huart2, Motor_Recv_Buf, Motor_Buf_Max_Len, MotorConfig.sendRecvTimeout);
   printfRecvBuf(id, "Motor_RunS");
}

void Motor_RunN(uint8_t id, uint32_t rpm) {
   uint8_t buf[10] = { Motor_FRAME_HEADER1, Motor_FRAME_HEADER2, id, 0x01, Motor_RUNN, 0x00, GET_HIGH_BYTE(rpm), GET_LOW_BYTE(rpm), checksum(buf), Motor_FRAME_END };
   send(buf, 10);

   if (!MotorConfig.isGetSpeed) {
      return;
   }

   // 返回 0XAA+id（只返回1个字节）
   HAL_UART_Receive(&huart2, Motor_Recv_Buf, Motor_Buf_Max_Len, MotorConfig.sendRecvTimeout);
   // printfRecvBuf(id, "Motor_RunN");
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
   send(buf, 10);

   if (!MotorConfig.isGetSpeed) {
      return;
   }

   // 返回 0XAA+id（只返回1个字节）
   HAL_UART_Receive(&huart2, Motor_Recv_Buf, Motor_Buf_Max_Len, MotorConfig.sendRecvTimeout);
   // printfRecvBuf(id, "Motor_Turnoff_Led");
}

// 该接口为阻塞接收, 会有延迟!!! 慎用, 当不使用该接口时, 其它Motor_XXX接口可以不接收返回的一个字节! 充分利用CPU资源
void Motor_Speed(uint8_t id) {
   if (!MotorConfig.isGetSpeed) {
      return;
   }

   uint8_t buf[10] = { Motor_FRAME_HEADER1, Motor_FRAME_HEADER2, id, Motor_READ_ANGLE, 0x00, 0x00, 0x00, 0x00, checksum(buf), Motor_FRAME_END };
   send(buf, 10);

   HAL_UART_Receive(&huart2, Motor_Recv_Buf, Motor_Buf_Max_Len, MotorConfig.sendRecvTimeout);
   printfRecvBuf(id, "Motor_Speed");
   parseSpeed(id);
}

void Motor_Init() {
   // 单片机--马达 要求使用半双工模式
   // 马达--控制板--单片机, 可以使用全双工模式
   // 本工程将控制板接在STM32C8T6的USART2(PA2, PA3)上, 全双工模式
   //   控制板       STM32C8T6
   //   5v            3.3v             可以不接VCC
   //   GND           GND              GND必须接!!!
   //   TX            PA2(USART2_TX)   控制板的TX和RX反了!!!必须这样接!!!
   //   RX            PA3(USART2_RX)

   Motor_Turnoff_Led(1); // 关掉电机1的LED
   Motor_Turnoff_Led(2); // 关掉电机2的LED

   Motor_RunN(1, 0); //电机1停止
   Motor_RunN(2, 0); //电机2停止

   MotorConfig.isGetSpeed      = 0; // 不从电机获取速度, 提高系统响应及性能
   MotorConfig.sendRecvTimeout = 10;
   MotorConfig.speedLevel      = 3;
}
