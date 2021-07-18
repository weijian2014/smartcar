#ifndef _SMARTCAR_ESP01S_H_
#define _SMARTCAR_ESP01S_H_

#include "stdint.h"

#define ESP01S_Buf_Max_Len 128
extern uint8_t  ESP01S_Recv_Buf[ESP01S_Buf_Max_Len];
extern uint32_t ESP01S_Recv_Size;

void ESP01S_Init();

#endif // _SMARTCAR_ESP01S_H_
