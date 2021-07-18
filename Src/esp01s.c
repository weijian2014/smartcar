#include "ESP01S.h"
#include "stdio.h"  // sprintf
#include "string.h" //  memset
#include "usart.h"

uint8_t ESP01S_Recv_Buf[ESP01S_Recv_Buf_LEN];

void ESP01S_Init() {
   // ESP01S接在USART1上,上电自动设置为station模式, 自动接入wifi:xiaoj,自动以TCP客户端连接192.168.2.102:8888

   // 配置USART1的中断优先级并打开USART1的中断开关
   HAL_NVIC_SetPriority(USART1_IRQn, 0, 0);
   HAL_NVIC_EnableIRQ(USART1_IRQn);

   // 打开USART1的DMA接收
   HAL_UART_Receive_DMA(&huart1, ESP01S_Recv_Buf, ESP01S_Recv_Buf_LEN);

   // 开启USART1的IDLE中断, IDLE就是串口收到一帧数据(一次发来的数据)后，发生的中断.
   // RXNE中断和IDLE中断的区别:当接收到1个字节，就会产生RXNE中断，当接收到一帧数据，就会产生IDLE中断
   // USART_ISR 状态寄存器, Bit4是IDLE寄存器, Bit5是RXNE寄存器. 当串口接收到数据时，bit5就会自动变成1，当接收完一帧数据后，bit4就会变成1
   // 需要注意的是，在中断函数里面，需要把对应的位清0，否则会影响下一次数据的接收
   __HAL_UART_ENABLE_IT(&huart1, UART_IT_IDLE);

   printf("ESP01S init ok\n");
}

// USART1中断后的处理入口
void USART1_IRQHandler(void) {
   // 该函数关闭USART1的中断, 接收数据,并调用HAL_UART_RxCpltCallback回调
   // HAL_UART_IRQHandler(&huart1);

   // 判断是否为USART1的IDLE中断
   if (__HAL_UART_GET_IT_SOURCE(&huart1, UART_IT_IDLE) != RESET) {
      __HAL_UART_CLEAR_IDLEFLAG(&huart1);                                                    // 清除中断标记
      HAL_UART_DMAStop(&huart1);                                                             // 停止DMA接收
      uint32_t recvLen         = ESP01S_Recv_Buf_LEN - __HAL_DMA_GET_COUNTER(huart1.hdmarx); // 总数据量减去未接收到的数据量为已经接收到的数据量
      ESP01S_Recv_Buf[recvLen] = '\0';                                                       // 添加结束符
      printf("ESP01S revc temp=[%ld], data=[%s]\n", recvLen, ESP01S_Recv_Buf);
      HAL_UART_Receive_DMA(&huart1, ESP01S_Recv_Buf, ESP01S_Recv_Buf_LEN); // 重新启动DMA接收
   }
}

// void HAL_UART_RxCpltCallback(UART_HandleTypeDef* huart) {
//    if (huart->Instance == USART1) {
//       printf("ESP01S revc data=[%s]\n", ESP01S_Recv_Buf);
//       memset(ESP01S_Recv_Buf, 0, ESP01S_Recv_Buf_LEN);
//       // 重新打开USART1的接收中断
//       HAL_UART_Receive_IT(huart, ESP01S_Recv_Buf, ESP01S_Recv_Buf_LEN - 1);
//    }

// }
