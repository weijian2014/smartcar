#ifndef _SMARTCAR_RING_H_
#define _SMARTCAR_RING_H_

#include "stdint.h"

#define RING_QUEUE_OK 0
#define RING_QUEUE_ERROR -1

typedef struct {
   uint32_t head;
   uint32_t tail;
   uint32_t lenght;
   uint32_t maxLen;
   uint8_t* buff;
} RingQueue;

int8_t Ring_Queue_Init(RingQueue* ringQueue, uint8_t* buff, uint32_t buffMaxLen);

int8_t Ring_Queue_Write_Data(RingQueue* ringQueue, uint8_t* data, uint32_t len);

int8_t Ring_Queue_Read_Data(RingQueue* ringQueue, uint8_t* data, uint32_t len);

// 读取数据但不删除
int8_t Ring_Queue_Peek_Data(RingQueue* ringQueue, uint8_t* data, uint32_t len);

#endif // _SMARTCAR_RING_H_
