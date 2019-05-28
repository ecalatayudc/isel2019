#include <string.h>
#include <stdio.h>
#include "esp_common.h"
#include "gpio.h"
#include "freertos/task.h"
#include "fsm.h"

#define GPIO_BUTTON1 14
#define GPIO_BUTTON2 16
#define GPIO_PIR 12
#define GPIO_ALARM 2

fsm_t* fsm_new_light (int* validp, int pir, int light,int button);
fsm_t* fsm_new_alarm (int* validp, int pir, int alarm);
fsm_t* fsm_new_code (int* validp, int button);

/******************************************************************************
 * FunctionName : user_rf_cal_sector_set
 * Description  : SDK just reversed 4 sectors, used for rf init data and paramters.
 *                We add this function to force users to set rf cal sector, since
 *                we don't know which sector is free in user's application.
 *                sector map for last several sectors : ABCCC
 *                A : rf cal
 *                B : rf init data
 *                C : sdk parameters
 * Parameters   : none
 * Returns      : rf cal sector
*******************************************************************************/
uint32 user_rf_cal_sector_set(void)
{
    flash_size_map size_map = system_get_flash_size_map();
    uint32 rf_cal_sec = 0;
    switch (size_map) {
        case FLASH_SIZE_4M_MAP_256_256:
            rf_cal_sec = 128 - 5;
            break;

        case FLASH_SIZE_8M_MAP_512_512:
            rf_cal_sec = 256 - 5;
            break;

        case FLASH_SIZE_16M_MAP_512_512:
        case FLASH_SIZE_16M_MAP_1024_1024:
            rf_cal_sec = 512 - 5;
            break;

        case FLASH_SIZE_32M_MAP_512_512:
        case FLASH_SIZE_32M_MAP_1024_1024:
            rf_cal_sec = 1024 - 5;
            break;

        default:
            rf_cal_sec = 0;
            break;
    }

    return rf_cal_sec;
}

static int valid_code = 0;

static void
alarm (void* ignore)
{
    fsm_t* code_fsm = fsm_new_code (&valid_code, GPIO_BUTTON1);
    fsm_t* alarm_fsm = fsm_new_alarm (&valid_code, GPIO_PIR, GPIO_ALARM);
    fsm_t* light_fsm = fsm_new_light (&valid_code, GPIO_PIR, GPIO_ALARM,GPIO_BUTTON2);
    portTickType period =  250 /portTICK_RATE_MS;
    portTickType last = xTaskGetTickCount();
    while (1) {
   	type Cycle is mod 4;
	Frame : Cycle := 0;
      		Wait_for_Interrupt;
		case Frame is
		  when 0 => fsm_fire (code_fsm);fsm_fire (light_fsm); fsm_fire (alarm_fsm);
		  when 1 => fsm_fire (code_fsm);
		  when 2 => fsm_fire (code_fsm);fsm_fire (light_fsm); 
		  when 3 => fsm_fire (code_fsm);
		  when 4 => fsm_fire (code_fsm);fsm_fire (light_fsm);
		end case;
      	Frame := Frame + 1;
    }
}

void
user_init (void)
{
    xTaskHandle task_alarm;
    xTaskCreate (alarm, "alarm", 2048, NULL, 1, &task_alarm);
}
