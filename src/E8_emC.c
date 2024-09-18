#include "stm32f1xx.h"
#include <time.h>

// Definição dos pinos
#define S1      0
#define S2      1
#define MOTOR   2	// LED Verde
#define INJETOR 3	// LED Vermelho

void delay(int segundos)// alternativa a função sleep() da windows.h/unistd.h
{
    int mili_segundos = 1000*segundos;
    clock_t start_time = clock();
    while (clock() <= start_time + mili_segundos);   // espera delay
}

int main(void) {
    RCC->APB2ENR |= RCC_APB2ENR_IOPAEN; // Habilita clock no barramento APB2 para GPIOA
    
    GPIOA->CRL = 0x44446688;// PA0/PA1: Estradas pull-up; PA2/PA3: Saídas open-drain 2Mhz
    GPIOA->ODR |= (1 << S1) | (1 << S2);// configurando os pinos pull-up

    GPIOA->BSRR = (1 << INJETOR);           // Começa com Injetor Desligado
    while (1) {
        GPIOA->BRR = (1 << MOTOR);          // Liga Motor
        while (GPIOA->IDR & (1 << S1));     // Espera Sensor 1
        // Quando S1 for ativado:
        GPIOA->BSRR = (1 << MOTOR);         // Desliga Motor
        GPIOA->BRR = (1 << INJETOR);        // Liga Injetor
        while (GPIOA->IDR & (1 << S2));     // Espera Sensor 2
        // Quando S1 for ativado:
        GPIOA->BSRR = (1 << INJETOR);       // Desliga Injetor
        delay(2);                           // Espera 2 segundos
    }

    return 0;
}
