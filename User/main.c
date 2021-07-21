#include "main.h"
#include "dma.h"
#include "esp01s.h"
#include "gpio.h"
#include "i2c.h"
#include "stdio.h" // printf
#include "usart.h"

#if 1
// 将标准输出重定向到USART2上, 这样可以使用printf打印到USART2
#ifdef __GNUC__
#define PUTCHAR_PROTOTYPE int __io_putchar(int ch)
#else
#define PUTCHAR_PROTOTYPE int fputc(int ch, FILE* f)
#endif

PUTCHAR_PROTOTYPE {
   uint8_t temp[1] = { ch };
   HAL_UART_Transmit(&huart2, temp, 1, 0xffff);
   return ch;
}

int _write(int file, char* ptr, int len) {
   int DataIdx;
   for (DataIdx = 0; DataIdx < len; DataIdx++) {
      __io_putchar(*ptr++);
   }
   return len;
}
// 将标准输出重定向到USART1上, 这样可以使用printf打印到USART1
#endif

void SystemClock_Config(void);

int main(void) {
   HAL_Init();
   SystemClock_Config();
   MX_GPIO_Init();
   MX_DMA_Init();
   MX_I2C1_Init();
   MX_USART1_UART_Init();
   MX_USART2_UART_Init();

   ESP01S_Init();
   uint32_t len = 0;
   uint8_t  echo[ESP01S_Buf_Max_Len + 32];
   uint8_t  buf[10];

   // FA AF 01 01 FD 00 02 58 59 ED
   buf[0] = 0xFA;
   buf[1] = 0xAF;
   buf[2] = 0x01;
   buf[3] = 0x01;
   buf[4] = 0xFD;
   buf[5] = 0x00;
   buf[6] = 0x02;
   buf[7] = 0x58;
   buf[8] = 0x59;
   buf[9] = 0xED;

   while (1) {
      // HAL_Delay(500);
      // HAL_GPIO_TogglePin(GPIOC, GPIO_PIN_13);

      if (ESP01S_Recv_Size > 0) {
         len = sprintf((char*)echo, "Recv from ESP01S, len=[%ld], data=[%s]\n", ESP01S_Recv_Size, ESP01S_Recv_Buf);
         HAL_UART_Transmit_DMA(&huart1, echo, len);
         ESP01S_Recv_Size = 0;
         HAL_GPIO_TogglePin(GPIOC, GPIO_PIN_13);
      }

      // HAL_HalfDuplex_EnableTransmitter(&huart2); // 为半双工模式要求每次发送和接收都需要使能相应的功能
      // HAL_HalfDuplex_EnableReceiver(&huart2);
      // printf("%s", ESP01S_Recv_Buf);
      // HAL_UART_Transmit(&huart2, buf, 10, 100);
   }
}

void SystemClock_Config(void) {
   RCC_OscInitTypeDef RCC_OscInitStruct = { 0 };
   RCC_ClkInitTypeDef RCC_ClkInitStruct = { 0 };

   /** Initializes the RCC Oscillators according to the specified parameters
    * in the RCC_OscInitTypeDef structure.
    */
   RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSE;
   RCC_OscInitStruct.HSEState       = RCC_HSE_ON;
   RCC_OscInitStruct.HSEPredivValue = RCC_HSE_PREDIV_DIV1;
   RCC_OscInitStruct.HSIState       = RCC_HSI_ON;
   RCC_OscInitStruct.PLL.PLLState   = RCC_PLL_ON;
   RCC_OscInitStruct.PLL.PLLSource  = RCC_PLLSOURCE_HSE;
   RCC_OscInitStruct.PLL.PLLMUL     = RCC_PLL_MUL9;
   if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK) {
      Error_Handler();
   }
   /** Initializes the CPU, AHB and APB buses clocks
    */
   RCC_ClkInitStruct.ClockType      = RCC_CLOCKTYPE_HCLK | RCC_CLOCKTYPE_SYSCLK | RCC_CLOCKTYPE_PCLK1 | RCC_CLOCKTYPE_PCLK2;
   RCC_ClkInitStruct.SYSCLKSource   = RCC_SYSCLKSOURCE_PLLCLK;
   RCC_ClkInitStruct.AHBCLKDivider  = RCC_SYSCLK_DIV1;
   RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV2;
   RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;

   if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_2) != HAL_OK) {
      Error_Handler();
   }
}

void Error_Handler(void) {
   /* USER CODE BEGIN Error_Handler_Debug */
   /* User can add his own implementation to report the HAL error return state */
   __disable_irq();
   while (1) {
   }
   /* USER CODE END Error_Handler_Debug */
}

#ifdef USE_FULL_ASSERT
/**
 * @brief  Reports the name of the source file and the source line number
 *         where the assert_param error has occurred.
 * @param  file: pointer to the source file name
 * @param  line: assert_param error line source number
 * @retval None
 */
void assert_failed(uint8_t* file, uint32_t line) {
   /* USER CODE BEGIN 6 */
   /* User can add his own implementation to report the file name and line number,
      ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
   /* USER CODE END 6 */
}
#endif /* USE_FULL_ASSERT */
