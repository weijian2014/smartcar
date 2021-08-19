#include "esp01s.h"
#include "stdio.h"  // sprintf
#include "string.h" //  memset
#include "usart.h"

uint8_t  ESP01S_Recv_Buf[ESP01S_Buf_Max_Len]; // 串口接收到的数据
uint32_t ESP01S_Recv_Size = 0;

uint8_t ESP01S_Send_Buf[ESP01S_Buf_Max_Len]; // 发送给串口的数据

ring_buffer* RB = NULL;

const char Hex_Table[] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F' };

void To_Hex(char* src, int len, char* dest) {
   dest[2 * len] = '\0';
   while (len--) {
      *(dest + 2 * len + 1) = Hex_Table[(*(src + len)) & 0x0f];
      *(dest + 2 * len)     = Hex_Table[(*(src + len)) >> 4];
   }
}

void ESP01S_Rst() {
   HAL_UART_Transmit_DMA(&huart1, (uint8_t*)"+++", 3);
   HAL_Delay(5);
   HAL_UART_Transmit_DMA(&huart1, (uint8_t*)"AT+RST\r\n", 8);
}

void ESP01S_Init(ring_buffer* ring_buffer_handle) {
   RB = ring_buffer_handle;

   // ESP01S更新固件需要按说明文档中的接线方法, 把所有引脚都接上. 可以使用USB转TTL的5V, 把所有的引脚都与USB转TTL的引脚接在一起, 3.3V和GND可以扩展再接
   //   ESP01S     USB转TTL
   //   3.3V         5V
   //   RST          5V
   //   EN           5V
   //   IO2          5V
   //   GND          GND
   //   IO0          GND
   //   TX           RX
   //   RX           TX

   // ESP01S连接USB转TTL进行调试的接线如下, 可以使用USB转TTL的5V
   //   ESP01S     USB转TTL
   //   3.3V         5V
   //   GND          GND
   //   TX           RX
   //   RX           TX

   // ESP01S接在STM32C8T6的USART1(PA9, PA10)上
   //   ESP01S      STM32C8T6
   //   3.3v          3.3v
   //   GND           GND
   //   RX            PA9(USART1_TX)
   //   TX            PA10(USART1_RX)

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
   // HAL_NVIC_DisableIRQ(DMA1_Channel4_IRQn); // 关闭DMA1第4通道的中断
   // __HAL_UART_DISABLE_IT(&huart1, UART_FLAG_TXE);

   // 开启USART1的IDLE中断, IDLE就是串口收到一帧数据(一次发来的数据)后，发生的中断.
   // RXNE中断和IDLE中断的区别:当接收到1个字节，就会产生RXNE中断，当接收到一帧数据，就会产生IDLE中断
   // USART_ISR 状态寄存器, Bit4是IDLE寄存器, Bit5是RXNE寄存器. 当串口接收到数据时，bit5就会自动变成1，当接收完一帧数据后，bit4就会变成1
   // 需要注意的是，在中断函数里面，需要把对应的位清0，否则会影响下一次数据的接收
   __HAL_UART_ENABLE_IT(&huart1, UART_IT_IDLE);

   // 上电后重置一下
   ESP01S_Rst();

   printf("ESP01S init ok\n");
}

// USART1中断后的处理入口
void USART1_IRQHandler(void) {
   // 这个必须调用
   HAL_UART_IRQHandler(&huart1);

   // 判断是否为USART1的IDLE中断
   // if (__HAL_UART_GET_FLAG(&huart1, UART_FLAG_IDLE) != RESET) {
   if (__HAL_UART_GET_IT_SOURCE(&huart1, UART_IT_IDLE) != RESET) {
      __HAL_UART_CLEAR_IDLEFLAG(&huart1);                                           // 清除IDLE中断标记
      HAL_UART_AbortReceive(&huart1);                                               // 停止DMA接收
      ESP01S_Recv_Size = ESP01S_Buf_Max_Len - __HAL_DMA_GET_COUNTER(huart1.hdmarx); // 总数据量减去未接收到的数据量为已经接收到的数据量

      if (ESP01S_Recv_Size) {
         // ESP01S_Recv_Buf[ESP01S_Recv_Size] = '\0';
         // printf("ESP01S_Recv_Buf=[%s], ESP01S_Recv_Size=[%ld]\n", ESP01S_Recv_Buf, ESP01S_Recv_Size);

         uint8_t oneMsgLength = ESP01S_Recv_Buf[0];
         if (oneMsgLength == ESP01S_Recv_Size) {
            if (RING_BUFFER_SUCCESS != Ring_Buffer_Write_String(RB, ESP01S_Recv_Buf, ESP01S_Recv_Size)) {
               printf("USART3 - Recv from ESP01S, len=[%ld], data=[%s] add to ring queue fail\n", ESP01S_Recv_Size, ESP01S_Recv_Buf);
               // 直接丢弃
               ESP01S_Recv_Size = 0;
            }
            else {
               Ring_Buffer_Insert_Keyword(RB, SEPARATE_SIGN, SEPARATE_SIGN_SIZE);
            }
         }
      }

      HAL_UART_Receive_DMA(&huart1, ESP01S_Recv_Buf, ESP01S_Buf_Max_Len); // DMA_NORMAL需要重新启动DMA接收, 如果是DMA_CIRCULAR模式, 则不需要再次启动
   }
}
