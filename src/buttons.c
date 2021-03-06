/**
 * @file    buttons.c
 * @author  Nikolay
 * @license MIT
 * @date    2020-07-05
 * @brief   File contains functions for buttons handlings
 *
 * Buttons connected for C.4 C.5 C.6
 * Interrups should be enabled
 */

#include "stm8s.h"
#include "stm8s_gpio.h"
#include "stm8s_exti.h"
#include "buttons.h"
#include "message.h"
#include "debug.h"

#define BUTTON_GPIO_GROUP      GPIOC

#define BUTTON_UP_GPIO_PIN    GPIO_PIN_4
#define BUTTON_DOWN_GPIO_PIN  GPIO_PIN_6
#define BUTTON_MODE_GPIO_PIN  GPIO_PIN_5

#define BUTTON_DELAY_MS       (10)
/**
 * @brief         Initialize buttons gpio
 */
void buttons_init() {
    EXTI_SetExtIntSensitivity(EXTI_PORT_GPIOC,
                              EXTI_SENSITIVITY_RISE_FALL);

    GPIO_Init(BUTTON_GPIO_GROUP,
              BUTTON_UP_GPIO_PIN,
              GPIO_MODE_IN_PU_IT);
    GPIO_Init(BUTTON_GPIO_GROUP,
              BUTTON_DOWN_GPIO_PIN,
              GPIO_MODE_IN_PU_IT);
    GPIO_Init(BUTTON_GPIO_GROUP,
              BUTTON_MODE_GPIO_PIN,
              GPIO_MODE_IN_PU_IT);
}
/**
 * @brief         Control buttons irq
 * @param[in]     en - new interrupt status
 */
void button_set_irq_en(bool en) {
    disableInterrupts();
    if(en) {
        BUTTON_GPIO_GROUP->CR2 |= (BUTTON_UP_GPIO_PIN |
                                 BUTTON_DOWN_GPIO_PIN |
                                 BUTTON_MODE_GPIO_PIN);
    } else {
        BUTTON_GPIO_GROUP->CR2 &= ~(BUTTON_UP_GPIO_PIN |
                                   BUTTON_DOWN_GPIO_PIN |
                                   BUTTON_MODE_GPIO_PIN);
    }
    enableInterrupts();
}
/**
 * @brief         Read current buttons values and sends
 *                corresponding messages
 */
void buttons_send_status() {
    uint8_t pins = GPIO_ReadInputData(BUTTON_GPIO_GROUP);
    if(!(pins & BUTTON_UP_GPIO_PIN)) {
        message_send(MESSAGE_UP_BUTTON, 0);
    }
    if(!(pins & BUTTON_DOWN_GPIO_PIN)) {
        message_send(MESSAGE_DOWN_BUTTON, 0);
    }
    if(!(pins & BUTTON_MODE_GPIO_PIN)) {
        message_send(MESSAGE_MODE_BUTTON, 0);
    }
    if((pins & (BUTTON_UP_GPIO_PIN |
               BUTTON_DOWN_GPIO_PIN |
                BUTTON_MODE_GPIO_PIN)) ==
       (BUTTON_UP_GPIO_PIN |
        BUTTON_DOWN_GPIO_PIN |
        BUTTON_MODE_GPIO_PIN)) {
        message_send(MESSAGE_BUTTONS_RELEASED, BUTTON_DELAY_MS);
    }

}
/**
 * @brief         GPIO C IRQ handler
 * @details       function sends message to main module
 *                that was reseived after delay. needed for
 *                contact bounce compensation
 */
void buttons_irq_handler() {
    message_send(MESSAGE_BUTTONS_IRQ, BUTTON_DELAY_MS);
    button_set_irq_en(0);
}
