#include "ring.h"
#include "string.h"

RingQueue ring;

void Ring_Queue_Init() {
   memset(&ring, 0, sizeof(RingQueue));
}

int8_t addDataToRingQueue(uint8_t* data, uint8_t len) {
   if (ring.lenght + len >= Ring_Queue_Max_Len) {
      return -1;
   }

   memcpy(ring.buff + ring.tail, data, len);
   ring.tail = (ring.tail + len) % Ring_Queue_Max_Len;
   ring.lenght += len;
   return 0;
}

uint8_t* getDataFromRingQueue(uint8_t* len) {
   if (ring.lenght == 0) {
      return NULL;
   }

   const uint8_t oneMsgLen = ring.buff[ring.head];
   if (ring.lenght < oneMsgLen) {
      return NULL;
   }

   const uint8_t* oneMsgData = ring.buff + ring.head;
   ring.head                 = (ring.head + oneMsgLen) % Ring_Queue_Max_Len;
   ring.lenght -= oneMsgLen;

   *len = oneMsgLen;
   return oneMsgData;
}

uint16_t ringQueueLength() {
   return ring.lenght;
}
