#ifndef _SMARTCAR_SERVO_H_
#define _SMARTCAR_SERVO_H_

#include "stdint.h"

extern uint8_t Servo_Current_Angle;

void Servo_Turn_Abs_Angle(uint8_t angle);

// void Servo_Turn_Right(uint8_t angle);

// void Servo_Turn_Left(uint8_t angle);

void Servo_Init();

#endif // _SMARTCAR_SERVO_H_
