#include "mcc_generated_files/mcc.h"
#include <string.h>
#include <pic18f57q43.h>

unsigned char prueba = 0;
unsigned char auxiliar = 0;
unsigned char receivedData = 3;

void UART1_String_Send(const char *string) {
    unsigned char tam;
    unsigned char i = 0;
    tam = strlen(string);
    for (i = 0; i < tam; i++) {
        UART1_Write(string[i]);
    }
}

void UART1_NewLine(void) {
    UART1_Write(0x0A);
    UART1_Write(0x0D);
}


void baja_tapa(void){
     LATCbits.LATC1 = 1;
     __delay_us(2500);
     LATCbits.LATC1 = 0;
     __delay_us(17500);
}

void sube_tapa(void){
     LATCbits.LATC1 = 1;
     __delay_us(500);
     LATCbits.LATC1 = 0;
     __delay_us(19500);
}

void pone_piso(void){
    LATCbits.LATC0 = 1;
    __delay_us(550);
    LATCbits.LATC0 = 0;
    __delay_us(19450);
}

void saca_piso(void){
    LATCbits.LATC0 = 1;
    __delay_us(2500);
    LATCbits.LATC0 = 0;
    __delay_us(17500);
}

void main(void) {
    SYSTEM_Initialize();
    TRISB = 0xFF;   // Configura RB0-RB3 como entradas
    ANSELB = 0x00;  // Configura PORTB como digital
    TRISD = 0x00;   // Configura PORTD como salidas
    ANSELD = 0x00;  // Configura PORTD como digital
    LATD = 0xF0;    // Inicializa LATD en 0
    TRISCbits.TRISC0 = 0;   //RC0 salida
    ANSELCbits.ANSELC0 = 0;  //RC0 digital
    TRISCbits.TRISC1 = 0;   //RC0 salida
    ANSELCbits.ANSELC1 = 0;  //RC0 digital
    TRISEbits.TRISE0 = 0;   //RE0 salida
    ANSELEbits.ANSELE0 = 0;  //RE0 digita
    TRISEbits.TRISE1 = 0;   //RE0 salida
    ANSELEbits.ANSELE1 = 0;  //RE0 digita
    pone_piso();
    pone_piso();
    pone_piso();
    pone_piso();

    while(1) {
        if (PORTBbits.RB0 == 1){
            LATDbits.LATD0 = 1;
            receivedData = '3';
            prueba = 0;
        }
        else{
            if(PORTBbits.RB1 == 1) {
            __delay_ms(300);
            LATDbits.LATD0 = 0;
            if(prueba == 0){
               UART1_String_Send("5\r\n");  // Envía '5' con terminador de línea (CR y LF)
                receivedData = '3'; 
                prueba = 1;
            }
            // Verifica si hay un dato disponible en UART después de que RB1 es igual a 1
            if (UART1_is_rx_ready()) {         // Comprueba si hay un dato en UART
                receivedData = UART1_Read();   // Lee el dato recibido
                LATDbits.LATD1 = 1;            // Enciende el LED en D1 (LATD1)
                LATDbits.LATD0 = 1;
                auxiliar = 1;
                __delay_ms(700);
                }
            }

            if(PORTBbits.RB2 == 1){
                 __delay_ms(940);
                    LATDbits.LATD0 = 0;
                    __delay_ms(2050);
                    switch (receivedData) {
                    case '0':  // Si recibe '0', enciende la motobomba A
                        LATDbits.LATD4 = 0;  // Enciende la motobomba A
                        __delay_ms(4000);           // Espera 2 segundos
                        LATDbits.LATD4 = 1;  // Desactiva la motobomba A
                        __delay_ms(4000);
                        receivedData = '3';
                        break;
                    case '1':  // Si recibe '1', apaga el LED
                        LATDbits.LATD5 = 0;  // Apaga el LED
                        __delay_ms(2400);           // Espera 2 segundos
                        LATDbits.LATD5 = 1;  // Desactiva la salida D1
                        __delay_ms(4000);
                        receivedData = '3';
                        break;
                    case '2':  // Si recibe '2', apaga el LED
                        LATDbits.LATD6 = 0;  // Apaga el LED
                        __delay_ms(2500);           // Espera 2 segundos
                        LATDbits.LATD6 = 1;  // Desactiva la salida D0
                        __delay_ms(4000);
                        receivedData = '3';
                        break;
                    default:  // Si recibe un comando no reconocido
                        break;
                    }
                    receivedData = '3';
                    LATDbits.LATD2 = 1;
                    LATDbits.LATD0 = 1;
                    __delay_ms(1000); 
                }
            }
            if(PORTBbits.RB3 == 1){
                if(auxiliar == 0){
                __delay_ms(2500);
                LATDbits.LATD0 = 0;
                } 
                else{
                LATDbits.LATD3 = 1;
                __delay_ms(1370);
                LATDbits.LATD0 = 0;
                __delay_ms(100);
                pone_piso();
                __delay_ms(100);
                pone_piso();
                __delay_ms(100);
                pone_piso();
                __delay_ms(100);
                pone_piso();
                __delay_ms(200);
                LATEbits.LATE0 = 0;
                LATEbits.LATE1 = 1; 
                auxiliar = 0;
                }
            }
            if(PORTBbits.RB5 == 1){
                __delay_ms(20);
                if(PORTBbits.RB5 == 1){
                LATEbits.LATE0 = 0;
                LATEbits.LATE1 = 0;
                __delay_ms(500);
                saca_piso();
                __delay_ms(100);
                saca_piso();
                __delay_ms(100);
                saca_piso();
                __delay_ms(100);
                saca_piso();
                __delay_ms(2000);
                /*LATEbits.LATE0 = 1;
                LATEbits.LATE1 = 0;
                __delay_ms(900);
                LATEbits.LATE0 = 0;
                LATEbits.LATE0 = 0;
                __delay_ms(1000);*/
                baja_tapa();
                __delay_ms(100);
                baja_tapa();
                __delay_ms(100);
                baja_tapa();
                __delay_ms(100);
                baja_tapa();
                __delay_ms(1000);
                sube_tapa();
                __delay_ms(100);
                sube_tapa();
                __delay_ms(100);
                sube_tapa();
                __delay_ms(100);
                sube_tapa();
                __delay_ms(1000);
                LATEbits.LATE0 = 1;
                LATEbits.LATE1 = 0;
                __delay_ms(600);
                 LATEbits.LATE0 = 0;
                LATEbits.LATE1 = 0;
                __delay_ms(1000);
                LATDbits.LATD0 = 1;
                __delay_ms(1000);
                LATD = 0xF0;
                auxiliar = 0;
                }
        }
        }
}

