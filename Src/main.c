#include <stdint.h>

#include "gd32vw55x.h"

#define LED_GPIO_PORT       GPIOC
#define LED_GPIO_PIN        GPIO_PIN_13
#define LED_GPIO_CLOCK      RCU_GPIOC

static void busy_wait_delay_ms(uint32_t milliseconds)
{
    while (milliseconds-- > 0U) {
        for (volatile uint32_t cycles = 0U; cycles < 16000U; ++cycles) {
            __asm volatile ("nop");
        }
    }
}

static void led_init(void)
{
    rcu_periph_clock_enable(LED_GPIO_CLOCK);
    gpio_mode_set(
        LED_GPIO_PORT,
        GPIO_MODE_OUTPUT,
        GPIO_PUPD_NONE,
        LED_GPIO_PIN
    );
    gpio_output_options_set(
        LED_GPIO_PORT,
        GPIO_OTYPE_PP,
        GPIO_OSPEED_10MHZ,
        LED_GPIO_PIN
    );
}

int main(void)
{
    led_init();

    while (1) {
        gpio_bit_toggle(LED_GPIO_PORT, LED_GPIO_PIN);
        busy_wait_delay_ms(500U);
    }
}
