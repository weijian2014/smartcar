#ifndef _SMARTCAR_MOTOR_H_
#define _SMARTCAR_MOTOR_H_

#include "stdint.h"

enum ControlMode { Control_Mode_Auto, Control_Mode_Remote };
enum Direction { Forward, Backward };

struct MotorConfigulation {
   uint8_t  controlMode;
   uint8_t  direction;
   uint16_t speedLevel;
   uint8_t  isGetSpeed;
   uint8_t  sendRecvTimeout;
};

extern struct MotorConfigulation MotorConfig;

// 电机顺时针转
void Motor_RunS(uint8_t id, uint32_t rpm);

// 电机逆时针转
void Motor_RunN(uint8_t id, uint32_t rpm);

// 获取电机转速, 会影响单片机响应速度
void Motor_Speed(uint8_t id);

void Motor_Init();

#endif // _SMARTCAR_MOTOR_H_
