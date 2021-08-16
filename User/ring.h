#ifndef _SMARTCAR_RING_H_
#define _SMARTCAR_RING_H_

#include "stdint.h"

#define Ring_Queue_Max_Len 1024

typedef struct {
   uint16_t head;
   uint16_t tail;
   uint16_t lenght;
   uint8_t  buff[Ring_Queue_Max_Len];
} RingQueue;

void Ring_Queue_Init();

int8_t addDataToRingQueue(uint8_t* data, uint8_t len);

uint8_t* getDataFromRingQueue(uint8_t* len);

uint16_t ringQueueLength();

#endif // _SMARTCAR_RING_H_
