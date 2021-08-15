#include "servo.h"
#include "stdio.h" // sprintf
#include "tim.h"

int8_t Current_Angle;

#define Angle_Index_Offset (45) // 角度下标的偏移
#define Min_Angle (45)
#define Max_Angle (135)

// 45度 ~ 90度 ~ 135度 的比较值
uint16_t Angle_Compare_value[91] = { 1280, 1287, 1293, 1300, 1307, 1314, 1320, 1327, 1334, 1340, 1347, 1354, 1360, 1367, 1374, 1381, 1387, 1394, 1401, 1407, 1414, 1421, 1427,
                                     1434, 1441, 1448, 1454, 1461, 1468, 1474, 1481, 1488, 1494, 1501, 1508, 1515, 1521, 1528, 1535, 1541, 1548, 1555, 1561, 1568, 1575, 1580,
                                     1591, 1602, 1613, 1624, 1636, 1647, 1658, 1669, 1680, 1691, 1702, 1713, 1724, 1735, 1747, 1758, 1769, 1780, 1791, 1802, 1813, 1824, 1835,
                                     1846, 1858, 1869, 1880, 1891, 1902, 1913, 1924, 1935, 1946, 1957, 1969, 1980, 1991, 2002, 2013, 2024, 2035, 2046, 2057, 2068, 2080

};

void Servo_Turn_Abs_Angle(uint8_t angle) {
   if (angle == 0) {
      return;
   }

   uint8_t angleIndex = angle - Angle_Index_Offset;
   __HAL_TIM_SET_COMPARE(&htim3, TIM_CHANNEL_1, Angle_Compare_value[angleIndex]);
}

void Servo_Turn_Right(uint8_t angle) {
   if ((Current_Angle + angle) > Max_Angle) {
      angle = Max_Angle - Current_Angle;
   }

   if (angle == 0) {
      return;
   }

   // 1280 --> 2080
   uint8_t angleIndex = Current_Angle + angle - Angle_Index_Offset;
   __HAL_TIM_SET_COMPARE(&htim3, TIM_CHANNEL_1, Angle_Compare_value[angleIndex]);
   Current_Angle += angle;
}

void Servo_Turn_Left(uint8_t angle) {
   if ((Current_Angle - angle) < Min_Angle) {
      angle = Current_Angle - Min_Angle;
   }

   if (angle == 0) {
      return;
   }

   // 2080 --> 1280
   uint8_t angleIndex = Current_Angle - angle - Angle_Index_Offset;
   __HAL_TIM_SET_COMPARE(&htim3, TIM_CHANNEL_1, Angle_Compare_value[angleIndex]);
   Current_Angle -= angle;
}

void Servo_Init() {
   // 方向舵机(TBS2701)的控制周期为20ms, 即1秒/20毫秒=50Hz的频率
   // 要想输出50Hz的频率, 假如定时器的时钟频率为72MHz, 预分频为72, 自动重装载值应为20000-1, 即72000000/72/20000=50Hz.
   // 使用TIM3的道道1, 输出引脚为PA6, tim.c已经对TIM3做了初始化, 包括中断.
   // 占空比: 1ms为0度(1000), 1.5ms为90度(1500), 2ms为180度(2000)

   HAL_TIM_PWM_Start(&htim3, TIM_CHANNEL_1);

   Current_Angle      = 90;
   uint8_t angleIndex = 90 - Angle_Index_Offset;
   __HAL_TIM_SET_COMPARE(&htim3, TIM_CHANNEL_1, Angle_Compare_value[angleIndex]); // 90度, 实际需要向180度偏移80个单位

   printf("Servo init ok\n");
}
