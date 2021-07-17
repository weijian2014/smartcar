#include "ESP01S.h"
#include "stdio.h"
#include "string.h"
#include "usart.h"

uint8_t ESP01S_Recv_Buf[8];

void ESP01S_Send_Cmd(const uint8_t* cmd) {
   uint8_t buf[16];
   int     len = sprintf((char*)buf, "%s\r\n", cmd);
   HAL_UART_Transmit(&huart1, buf, len, 1000);
}

void ESP01S_Ack(uint8_t* ack, uint16_t len) {
   HAL_UART_Receive(&huart1, ack, len, 1000);
}

void ESP01S_Init() {
   printf("ESP01S init...\n");

   // ESP01S接在USART1上,上电自动设置为station模式, 自动接入wifi:xiaoj,自动以TCP客户端连接192.168.2.102:8888

   // HAL_UART_Receive_IT(&huart1, ESP01S_Recv_Buf, 8);

   /*
      int     ret;
      uint8_t ack[16] = { 0 };

      // 恢复出厂设置
      do {
         ESP01S_Send_Cmd("AT+RESTORE");
         ESP01S_Ack(ack, 15);
         printf("AT+RESTORE, ack=[%s]\n", ack);
      } while (strcmp("\r\nOK\r\n", (const char*)ack) != 0);
      printf("ESP01S AT+RESTORE ok\n");

      AT
      do {
         ESP01S_Send_Cmd("AT");
         ESP01S_Ack(ack, 15);
         // printf("AT, ack=[%s]\n", ack);
      } while (strcmp("\r\nOK\r\n", (const char*)ack) != 0);
      printf("ESP01S AT ok\n");

      // ATE0
      do {
         ESP01S_Send_Cmd("ATE0");
         uint8_t ack[16] = { 0 };
         ESP01S_Ack(ack, 15);
         // printf("ATE0, ack=[%s]\n", ack);
      } while (strcmp("\r\nOK\r\n", (const char*)ack) != 0);
      printf("ESP01S ATE0 ok\n");

      // station模式
      do {
         ESP01S_Send_Cmd("AT+CWMODE=1");
         uint8_t ack[16] = { 0 };
         ESP01S_Ack(ack, 15);
         printf("AT+CWMODE=1, ack=[%s]\n", ack);
      } while (strcmp("\r\nOK\r\n", (const char*)ack) != 0);
      printf("ESP01S ATE0 ok\n");
   */

   printf("ESP01S is working\n");
}
