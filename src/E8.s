.text               // informa ao assembler que deve montar esse texto
.syntax unified     // usa sintaxe nova

// funções globais
.global MainAsm
.global ConfigReg
.global Liga_Motor
.global Espera_S1
.global Desliga_Motor
.global Liga_Injetor
.global Espera_S2
.global Desliga_Injetor
.global Delay2sec
.global Espera_Delay

// definições
.equ GPIOA_base, 0x40010800
.equ GPIOA_CRL, GPIOA_base + 0x00
.equ GPIOA_CRH, GPIOA_base + 0x04
.equ GPIOA_IDR, GPIOA_base + 0x08
.equ GPIOA_ODR, GPIOA_base + 0x0C
.equ GPIOA_BSRR, GPIOA_base + 0x10
.equ GPIOA_BRR, GPIOA_base + 0x14
.equ GPIOA_LCKR, GPIOA_base + 0x18

.equ RCC_APB2ENR, 0x40021018
.equ LED_DELAY,	4*0x000FFFFF

// Pins utilizados
.equ S1, 0          // PA0
.equ S2, 1          // PA1
.equ MOTOR, 2       // PA2
.equ INJETOR, 3     // PA3

MainAsm:
    BL ConfigReg
    BL Desliga_Injetor  // Começa com Injetor Desligado
LoopPrincipal:
    BL Liga_Motor
    BL Espera_S1
    BL Desliga_Motor
    BL Liga_Injetor
    BL Espera_S2
    BL Desliga_Injetor
    BL Delay2sec
    BL Espera_Delay
    B LoopPrincipal

ConfigReg:
    // Habilita clock APB2 no GPIOA
    LDR r6, =RCC_APB2ENR // --DCBA--
    MOV r0, #0x4      // 0b 00000100
    STR r0, [r6]

    // Config PA0 (S1) e PA1 (S2) como Entrada:
    // Entradas com resistor pull-up: CNF+MODE = 10 00 -> 0x8

    // Config PA2 (Motor, LED Verde) e PA3 (Injetor, LED Vermelho) como Saídas:
    // Ambas serão saídas open-drain de 2 MHz conectadas
    // a um LED para indicar motor e injetor ligados ou
    // desligados. Portanto: CNF+MODE = 01 10 -> 0x6

    // Considerando as informações acima sobre os quatro pinos
    // utilizados (PA0, PA1, PA2 e PA3), atualizamos as
    // configurações dos pinos do registrador GPIOA com o valor
    // 0x44446688
    LDR r6, =GPIOA_CRL
    LDR r0, =0x44446688
    STR r0, [r6]

    // e GPIOA_ODR = 1 nos pinos 0 e 1 (pull-up)
    LDR r6, =GPIOA_ODR
    LDR r0, =0x3    // 0b00.. 0011
    STR r0, [r6]
    BX lr

Liga_Motor:
    // PA2 = 0 com GPIOA_BRR
    LDR r0, =GPIOA_BRR
    LDR r1, =0x4    // 0b 0000 0000 0000 0100
    STR r1, [r0]
    BX lr

Espera_S1:
    // loop de espera até que o S1 seja ativado
    LDR r0, =GPIOA_IDR
    LDR r1, [r0]// le o conteudo de GPIOA_IDR
    TST r1, #(1 << S1)// PA0 AND 0b0...0001 pois S1=0
    BNE Espera_S1   // se Z = 1
    BX lr // Se Z=0, PA0 (S1) foi ativado

Desliga_Motor:
    // PA2 = 1 com GPIOA_BSRR
    LDR r0, =GPIOA_BSRR
    LDR r1, =0x4
    STR r1, [r0]
    BX lr

Liga_Injetor:
    // PA3 = 0 com GPIOA_BRR
    LDR r0, =GPIOA_BRR
    LDR r1, =0x8    // 0b 0000 0000 0000 1000
    STR r1, [r0]
    BX lr

Espera_S2:
    LDR r0, =GPIOA_IDR
    LDR r1, [r0]
    TST r1, #(1 << S2)// S2 = 1
    BNE Espera_S2
    BX lr

Desliga_Injetor:
    // PA3 = 0 com GPIOA_BSRR
    LDR r0, =GPIOA_BSRR
    LDR r1, =0x8
    STR r1, [r0]
    BX lr

Delay2sec:
    LDR	r0,	=LED_DELAY
    BX lr

Espera_Delay:
    SUBS	r0,#0x01
	BNE	Espera_Delay
    BX lr

	