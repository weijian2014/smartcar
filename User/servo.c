#include "servo.h"
#include "stdio.h" // sprintf
#include "tim.h"

int8_t Servo_Current_Angle;

#define Angle_Index_Offset (45) // 角度下标的偏移
#define Min_Angle (45)
#define Max_Angle (135)

// 舵机以坐标系-X轴为0度顺时针增加旋转角度
// 为了方便以正切角度（以坐标系+X轴为0度逆时针增加旋转角度）的方式控制舵机, 需要将比较值逆序(正切45度需要舵机135度的比较值)
// 将135度 ~ 90度 ~ 45度 的比较值, 实际需要向180度偏移80个单位
uint16_t Angle_Compare_value[91] = { 2080, 2068, 2057, 2046, 2035, 2024, 2013, 2002, 1991, 1980, 1969, 1957, 1946, 1935, 1924, 1913, 1902, 1891, 1880, 1869, 1858, 1846, 1835,
                                     1824, 1813, 1802, 1791, 1780, 1769, 1758, 1747, 1735, 1724, 1713, 1702, 1691, 1680, 1669, 1658, 1647, 1636, 1624, 1613, 1602, 1591, 1580,
                                     1575, 1568, 1561, 1555, 1548, 1541, 1535, 1528, 1521, 1515, 1508, 1501, 1494, 1488, 1481, 1474, 1468, 1461, 1454, 1448, 1441, 1434, 1427,
                                     1421, 1414, 1407, 1401, 1394, 1387, 1381, 1374, 1367, 1360, 1354, 1347, 1340, 1334, 1327, 1320, 1314, 1307, 1300, 1293, 1287, 1280 };

void Servo_Turn_Abs_Angle(uint8_t angle) {
   if (angle < Min_Angle || angle > Max_Angle) {
      return;
   }

   Servo_Current_Angle = angle;
   uint8_t angleIndex  = angle - Angle_Index_Offset;
   __HAL_TIM_SET_COMPARE(&htim3, TIM_CHANNEL_1, Angle_Compare_value[angleIndex]);
}

// void Servo_Turn_Right(uint8_t angle) {
//    if ((Servo_Current_Angle + angle) > Max_Angle) {
//       angle = Max_Angle - Servo_Current_Angle;
//    }

//    if (angle == 0) {
//       return;
//    }

//    // 1280 --> 2080
//    uint8_t angleIndex = Servo_Current_Angle + angle - Angle_Index_Offset;
//    __HAL_TIM_SET_COMPARE(&htim3, TIM_CHANNEL_1, Angle_Compare_value[angleIndex]);
//    Servo_Current_Angle += angle;
// }

// void Servo_Turn_Left(uint8_t angle) {
//    if ((Servo_Current_Angle - angle) < Min_Angle) {
//       angle = Servo_Current_Angle - Min_Angle;
//    }

//    if (angle == 0) {
//       return;
//    }

//    // 2080 --> 1280
//    uint8_t angleIndex = Servo_Current_Angle - angle - Angle_Index_Offset;
//    __HAL_TIM_SET_COMPARE(&htim3, TIM_CHANNEL_1, Angle_Compare_value[angleIndex]);
//    Servo_Current_Angle -= angle;
// }

void Servo_Init() {
   // 方向舵机(TBS2701)最大旋转角度270度，以坐标系-X轴为0度顺时针增加旋转角度。占空比: 1ms为0度(1000), 1.5ms为90度(1500), 2ms为180度(2000)
   // 方向舵机(TBS2701)的控制周期为20ms, 即1秒/20毫秒=50Hz的频率
   // 要想输出50Hz的频率, 假如定时器的时钟频率为72MHz, 预分频为72, 自动重装载值应为20000-1, 即72000000/72/20000=50Hz.
   // 使用TIM3的道道1, 输出引脚为PA6, tim.c已经对TIM3做了初始化, 包括中断.

   HAL_TIM_PWM_Start(&htim3, TIM_CHANNEL_1);

   Servo_Turn_Abs_Angle(90);

   printf("Servo init ok\n");
}
