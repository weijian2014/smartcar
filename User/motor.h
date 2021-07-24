#ifndef _SMARTCAR_MOTOR_H_
#define _SMARTCAR_MOTOR_H_

#include "stdint.h"

struct MotorConfigulation {
   uint8_t isGetSpeed;
   uint8_t sendRecvTimeout;
};

extern struct MotorConfigulation MotorConfig;

// FA 帧头1 | AF 帧头2 | ID | 指令 | 参数1H | 参数1L | 参数2H | 参数2L | 校验 | ED 结束码
// 指令:
//    0X01 电机控制转速
//    0X02 速度回读
//    0X04 电机内部灯控制指令
//    0XCD 修改ID

#define Motor_FRAME_HEADER1 0XFA
#define Motor_FRAME_HEADER2 0XAF
#define Motor_MOVE_ANGLE 0X01
#define Motor_READ_ANGLE 0X02
#define Motor_LED 0X04
#define Motor_ID_WRITE 0XCD
#define Motor_SET_OFFSET 0XD2
#define Motor_READ_OFFSET 0XD4
#define Motor_VERSION 0X01
#define Motor_FRAME_END 0XED
#define Motor_RUNS 0XFD // 顺时针转
#define Motor_RUNN 0XFE // 逆时针转

// 电机顺时针转
void Motor_RunS(uint8_t id, uint32_t rpm);

// 电机逆时针转
void Motor_RunN(uint8_t id, uint32_t rpm);

void Motor_Speed(uint8_t id);

void Motor_Init();

#endif // _SMARTCAR_MOTOR_H_
