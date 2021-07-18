#ifndef _SMARTCAR_ESP01S_H_
#define _SMARTCAR_ESP01S_H_

#include "stdint.h"

#define ESP01S_Recv_Buf_LEN 512
extern uint8_t ESP01S_Recv_Buf[ESP01S_Recv_Buf_LEN];

void ESP01S_Init();

#endif // _SMARTCAR_ESP01S_H_
