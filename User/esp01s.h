#ifndef _SMARTCAR_ESP01S_H_
#define _SMARTCAR_ESP01S_H_

#include "ring.h"
#include "stdint.h"

#define ESP01S_RECV_BUF_MAX_LEN 64

extern void To_Hex(char* src, int len, char* dest);

// 短整型大小端互换
#define BigLittleSwap16(A) ((((uint16)(A)&0xff00) >> 8) | (((uint16)(A)&0x00ff) << 8))

typedef enum {
   opt_echo,       // 用于测试, value = 0
   opt_config,     // APP下发配置给小车
   opt_ack,        // APP与STM32之间的消息确认
   opt_control,    // APP重力感应远程控制小车, 下发角度, 速度等
   opt_car_status, // 小车返回的状态,前进/后退, 马达转速/正向/反向, 舵机方向及角度等等
   opt_max,        // value = 5
} Operation_Type;

typedef enum { dir_forward = 1, dir_backward = 2 } Direction;

typedef struct {
   uint8_t totalLength;
   uint8_t optType;
   uint8_t direction;
   uint8_t angel;
   uint8_t level;
} ControlMessage;

void ESP01S_Rst();

void ESP01S_Init(RingQueue* ringQueue);

#endif // _SMARTCAR_ESP01S_H_
