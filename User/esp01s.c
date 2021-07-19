#include "ESP01S.h"
#include "stdio.h"  // sprintf
#include "string.h" //  memset
#include "usart.h"

uint8_t  ESP01S_Recv_Buf[ESP01S_Buf_Max_Len]; // 串口接收到的数据
uint32_t ESP01S_Recv_Size = 0;

uint8_t ESP01S_Send_Buf[ESP01S_Buf_Max_Len]; // 发送给串口的数据

void ESP01S_Init() {
   // ESP01S接在USART1上,上电自动设置为station模式, 自动接入wifi:xiaoj,自动以TCP客户端连接192.168.2.102:8888

   // 配置USART1的中断优先级并打开USART1的中断开关
   HAL_NVIC_SetPriority(USART1_IRQn, 0, 0);
   HAL_NVIC_EnableIRQ(USART1_IRQn);

   // DMA的中断在dma.c中的MX_DMA_Init()开启

   // 打开USART1的DMA接收
   // usart.c中的HAL_UART_MspInit()已经对USART1的接收(P-->M)DMA做了初始化, 使用DMA1的第5通道(表59)
   HAL_UART_Receive_DMA(&huart1, ESP01S_Recv_Buf, ESP01S_Buf_Max_Len);

   // 打开USART1的DMA发送
   // usart.c中的HAL_UART_MspInit()已经对USART1的发送(M-->P)DMA做了初始化, 使用DMA1的第4通道(表59)
   HAL_NVIC_DisableIRQ(DMA1_Channel4_IRQn); // 关闭DMA1第4通道的中断

   // 开启USART1的IDLE中断, IDLE就是串口收到一帧数据(一次发来的数据)后，发生的中断.
   // RXNE中断和IDLE中断的区别:当接收到1个字节，就会产生RXNE中断，当接收到一帧数据，就会产生IDLE中断
   // USART_ISR 状态寄存器, Bit4是IDLE寄存器, Bit5是RXNE寄存器. 当串口接收到数据时，bit5就会自动变成1，当接收完一帧数据后，bit4就会变成1
   // 需要注意的是，在中断函数里面，需要把对应的位清0，否则会影响下一次数据的接收
   __HAL_UART_ENABLE_IT(&huart1, UART_IT_IDLE);

   printf("ESP01S init ok\n");
}

// USART1中断后的处理入口
void USART1_IRQHandler(void) {
   // 这个必须调用
   HAL_UART_IRQHandler(&huart1);

   // 判断是否为USART1的IDLE中断
   // if (__HAL_UART_GET_FLAG(&huart1, UART_FLAG_IDLE) != RESET) {
   if (__HAL_UART_GET_IT_SOURCE(&huart1, UART_IT_IDLE) != RESET) {
      __HAL_UART_CLEAR_IDLEFLAG(&huart1); // 清除中断标记
      HAL_UART_AbortReceive(&huart1);     // 停止DMA接收

      ESP01S_Recv_Size                  = ESP01S_Buf_Max_Len - __HAL_DMA_GET_COUNTER(huart1.hdmarx); // 总数据量减去未接收到的数据量为已经接收到的数据量
      ESP01S_Recv_Buf[ESP01S_Recv_Size] = '\0';                                                      // 添加结束符
      printf("ESP01S revc recvLen=[%ld], data=[%s]\n", ESP01S_Recv_Size, ESP01S_Recv_Buf);

      HAL_UART_Receive_DMA(&huart1, ESP01S_Recv_Buf, ESP01S_Buf_Max_Len); // DMA_NORMAL需要重新启动DMA接收, 如果是DMA_CIRCULAR模式, 则不需要再次启动
   }
}
