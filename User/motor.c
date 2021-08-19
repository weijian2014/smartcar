#include "motor.h"
#include "stdio.h" // sprintf
#include "usart.h"

struct MotorConfigulation MotorConfig;

// 与电机交互的帧模式如下, 10个字节
// FA 帧头1 | AF 帧头2 | ID | 指令 | 参数1H | 参数1L | 参数2H | 参数2L | 校验 | ED 结束码
#define Motor_FRAME_HEADER1 0XFA // 帧头1
#define Motor_FRAME_HEADER2 0XAF // 帧头2
#define Motor_MOVE_ANGLE 0X01    // 电机控制转速
#define Motor_READ_ANGLE 0X02    // 读取电机转速
#define Motor_LED 0X04           // 电机内部灯控制指令
#define Motor_ID_WRITE 0XCD      // 设置电机ID号
#define Motor_SET_OFFSET 0XD2    // 设置电机偏移
#define Motor_READ_OFFSET 0XD4   // 读取电机偏移
#define Motor_VERSION 0X01       // 读取电机固件版本信息
#define Motor_FRAME_END 0XED     // 结束码
#define Motor_RUNS 0XFD          // 顺时针转
#define Motor_RUNN 0XFE          // 逆时针转

// 速度级别, 11档(0 - 0rpm, 1 - 270rpm, 2 - 370rpm, 3 - 470rpm, 4 - 570rpm, 5 - 670rpm, 6 - 770rpm, 7 - 870rpm, 8 - 970rpm, 9 - 1070rpm, 10 - 1170rpm)
uint16_t Speed_Rpm[Max_Speed_Level] = { 0, 270, 370, 470, 570, 670, 770, 870, 970, 1070, 1170 };

#define Motor_Buf_Max_Len 10
uint8_t Motor_Recv_Buf[Motor_Buf_Max_Len];

////////////////////////////////////////////////////////////////////////////////////////////

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

   if (0 == MotorConfig.isGetSpeed) {
      return;
   }

   // 返回 0XAA+id（只返回1个字节）
   HAL_UART_Receive(&huart2, Motor_Recv_Buf, Motor_Buf_Max_Len, MotorConfig.sendRecvTimeout);
   // printfRecvBuf(id, "Motor_RunS");
}

void Motor_RunN(uint8_t id, uint32_t rpm) {
   uint8_t buf[10] = { Motor_FRAME_HEADER1, Motor_FRAME_HEADER2, id, 0x01, Motor_RUNN, 0x00, GET_HIGH_BYTE(rpm), GET_LOW_BYTE(rpm), checksum(buf), Motor_FRAME_END };
   send(buf, 10);

   if (0 == MotorConfig.isGetSpeed) {
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

   if (0 == MotorConfig.isGetSpeed) {
      return;
   }

   // 返回 0XAA+id（只返回1个字节）
   HAL_UART_Receive(&huart2, Motor_Recv_Buf, Motor_Buf_Max_Len, MotorConfig.sendRecvTimeout);
   // printfRecvBuf(id, "Motor_Turnoff_Led");
}

// 该接口为阻塞接收, 会有延迟!!! 慎用, 当不使用该接口时, 其它Motor_XXX接口可以不接收返回的一个字节! 充分利用CPU资源
void Motor_Speed(uint8_t id) {
   if (0 == MotorConfig.isGetSpeed) {
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
   // 单片机--控制板--马达, 单片机可以使用全双工模式
   // PC COM口--MorcUSB--控制板--马达, 可以使用调试工具直接与马达通信
   // 本工程将控制板接在STM32C8T6的USART2(PA2, PA3)上, 全双工模式
   //   控制板       STM32C8T6
   //   5v            3.3v             可以不接VCC
   //   GND           GND              GND必须接!!!(双直流电源GND要共地)
   //   TX            PA2(USART2_TX)   控制板的TX和RX反了!!!必须这样接!!!
   //   RX            PA3(USART2_RX)

   MotorConfig.isGetSpeed      = 0; // 0表示不从电机获取电机转速, 提高系统响应及性能, 非0表示获取电机转速
   MotorConfig.sendRecvTimeout = 5; // 接收或发送的Timeout
   MotorConfig.speedLevel      = 3; // 速度级别, 10档(1-200rpm, 2-400rpm, 3-600rpm, 4-800rpm, 5-1000rpm, 6-1200rpm, 7-1400rpm, 8-1600rpm, 9-1800rpm, 10-2000rpm)

   Motor_Turnoff_Led(1); // 关掉电机1的LED
   Motor_Turnoff_Led(2); // 关掉电机2的LED

   Motor_RunN(1, 0); //电机1停止
   Motor_RunN(2, 0); //电机2停止

   printf("Motor init ok\n");
}
