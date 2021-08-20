#include "ring.h"
#include "string.h"

int8_t Ring_Queue_Init(RingQueue* ringQueue, uint8_t* buff, uint32_t buffMaxLen) {
   ringQueue->head   = 0;
   ringQueue->tail   = 0;
   ringQueue->lenght = 0;
   ringQueue->maxLen = buffMaxLen;
   ringQueue->buff   = buff;
   return RING_QUEUE_OK;
}

int8_t Ring_Queue_Write_Data(RingQueue* ringQueue, uint8_t* data, uint32_t len) {
   if ((ringQueue->lenght + len) > ringQueue->maxLen) {
      return RING_QUEUE_ERROR;
   }

   uint32_t tailFreeLen = ringQueue->maxLen - ringQueue->tail;
   if (tailFreeLen < len) {
      // 队尾空间不够, 将多余的数据从队头开始插入
      memcpy(ringQueue->buff + ringQueue->tail, data, tailFreeLen);
      memcpy(ringQueue->buff, data + tailFreeLen, len - tailFreeLen);
   }
   else {
      memcpy(ringQueue->buff + ringQueue->tail, data, len);
   }

   ringQueue->lenght += len;
   ringQueue->tail = (ringQueue->tail + len) % ringQueue->maxLen;
   return RING_QUEUE_OK;
}

int8_t Ring_Queue_Read_Data(RingQueue* ringQueue, uint8_t* data, uint32_t len) {
   if (ringQueue->lenght < len) {
      return RING_QUEUE_ERROR;
   }

   uint32_t tailDataLen = ringQueue->maxLen - ringQueue->head;
   if (tailDataLen < len) {
      // 队尾数据不够, 将从队头开始取出
      memcpy(data, ringQueue->buff + ringQueue->head, tailDataLen);
      memcpy(data + tailDataLen, ringQueue->buff, len - tailDataLen);
   }
   else {
      memcpy(data, ringQueue->buff + ringQueue->head, len);
   }

   ringQueue->lenght -= len;
   ringQueue->head = (ringQueue->head + len) % ringQueue->maxLen;

   return RING_QUEUE_OK;
}

int8_t Ring_Queue_Peek_Data(RingQueue* ringQueue, uint8_t* data, uint32_t len) {
   if (ringQueue->lenght < len) {
      return RING_QUEUE_ERROR;
   }

   uint32_t tailDataLen = ringQueue->maxLen - ringQueue->head;
   if (tailDataLen < len) {
      // 队尾数据不够, 将从队头开始取出
      memcpy(data, ringQueue->buff + ringQueue->head, tailDataLen);
      memcpy(data + tailDataLen, ringQueue->buff, len - tailDataLen);
   }
   else {
      memcpy(data, ringQueue->buff + ringQueue->head, len);
   }

   return RING_QUEUE_OK;
}
