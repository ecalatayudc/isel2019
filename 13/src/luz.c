#include <string.h>
#include <stdio.h>
#include "esp_common.h"
#include "gpio.h"
#include "freertos/task.h"
#include "fsm.h"

void gpio_config (GPIO_ConfigTypeDef *pGPIOConfig);
#define ETS_GPIO_INTR_ENABLE() _xt_isr_unmask ((1 << ETS_GPIO_INUM))

static int GPIO_pir = 12;
static int GPIO_btn = 14;
static int GPIO_light = 2;

static void
io_intr_handler (void)
{
  static portTickType debounce_timeout;
  portTickType now = xTaskGetTickCount();
  uint32 status = GPIO_REG_READ (GPIO_STATUS_ADDRESS);

  if (now >= debounce_timeout) {
      debounce_timeout = now + (200 /portTICK_RATE_MS);
      button = 1;
  }

  /* rearm interrupts */
  GPIO_REG_WRITE (GPIO_STATUS_W1TC_ADDRESS, status);
}

void
light_setup (int pir, int light,int btn)
{
  GPIO_ConfigTypeDef io_in_conf;

  GPIO_pir = pir;
  GPIO_btn = btn;
  GPIO_light = light;

  io_in_conf.GPIO_IntrType = GPIO_PIN_INTR_DISABLE;
  io_in_conf.GPIO_Mode = GPIO_Mode_Input;
  io_in_conf.GPIO_Pin = (1 << GPIO_pir);
  io_in_conf.GPIO_Pullup = GPIO_PullUp_EN;
  gpio_config (&io_in_conf);

  io_in_conf.GPIO_IntrType = GPIO_PIN_INTR_DISABLE;
  io_in_conf.GPIO_Mode = GPIO_Mode_Input;
  io_in_conf.GPIO_Pin = (1 << GPIO_btn);
  io_in_conf.GPIO_Pullup = GPIO_PullUp_EN;
  gpio_config (&io_in_conf);

  io_in_conf.GPIO_IntrType = GPIO_PIN_INTR_DISABLE;
  io_in_conf.GPIO_Mode = GPIO_Mode_Output;
  io_in_conf.GPIO_Pin = (1 << GPIO_light);
  io_in_conf.GPIO_Pullup = GPIO_PullUp_DIS;
  gpio_config (&io_in_conf);

  GPIO_OUTPUT_SET (GPIO_light, 1);
  puts ("Light: INIT");
  
  gpio_intr_handler_register ((void *) io_intr_handler, NULL);
  ETS_GPIO_INTR_ENABLE();
}


static int
presence (fsm_t* fsm)
{
    return ! GPIO_INPUT_GET (GPIO_pir);
}

btn(fsm_t* fsm)
{
    return ! GPIO_INPUT_GET (GPIO_btn);
}
static int
timeout (fsm_t* fsm)
{
    return !code_ok(fsm) && started && (xTaskGetTickCount() > digit_deadline);
}
static void
turn_on (fsm_t* fsm)
{
    GPIO_OUTPUT_SET (GPIO_light, 0);
    puts ("Luz: ON");
}

static void
turn_off (fsm_t* fsm)
{
    GPIO_OUTPUT_SET (GPIO_light, 1);
    puts ("LUZ:OFF");
}

fsm_t*
fsm_new_light (int* validp, int pir, int light,int btn)
{
    static fsm_trans_t light_tt[] = {
        {  0, btn, 1, turn_on },
        {  1, timeout_lamp, 0, turn_off },
        {  0, presence, 1, turn_on },
	{  1, btn, 1, turn_on },
        { -1, NULL, -1, NULL },
    };
    valid_code = validp;
    light_setup (pir, light,btn);
    return fsm_new (light_tt);
}
