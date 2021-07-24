#include "servo.h"
#include "tim.h"

void Servo_TurnS(uint8_t angle) {}

void Servo_TurnR(uint8_t angle) {}

void Servo_Init() {
   // 方向舵机(TBS2701)的控制周期为20ms, 即1秒/20毫秒=50Hz的频率
   // 要想输出50Hz的频率, 假如定时器的时钟频率为72MHz, 预分频为72-1, 自动重装载值应为20000-1, 即72000000/72/20000=50Hz.
   // 使用TIM3的道道1, 输出引脚为PA6, tim.c已经对TIM3做了初始化, 包括中断.
   // 占空比: 1ms为0度(1000), 1.5ms为90度(1500), 2ms为180度(2000)

   HAL_TIM_PWM_Start(&htim3, TIM_CHANNEL_1);

   __HAL_TIM_SET_COMPARE(&htim3, TIM_CHANNEL_1, 1500 - 1);
}
