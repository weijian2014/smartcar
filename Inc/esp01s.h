#ifndef _SMARTCAR_ESP01S_H_
#define _SMARTCAR_ESP01S_H_

#include "stdint.h"

extern uint8_t ESP01S_Recv_Buf[8];

void ESP01S_Init();

void ESP01S_Send_Cmd(const uint8_t* cmd);

void ESP01S_Ack(uint8_t* ack, uint16_t len);

#endif // _SMARTCAR_ESP01S_H_
