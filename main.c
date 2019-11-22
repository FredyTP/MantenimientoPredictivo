// Visualizacion de temperatura mediante 4 sensores I2C
// Grupo 7. Alfredo Torres, Ferran Bosi, Juan Robles

#include <p18f4520.h>
#include <stdlib.h>
#include "lcd.h"	// Libreria personalizada
#include <delays.h>
#include <i2c.h>
#include <usart.h>
#include <stdio.h>
#include "PIClib.h"

#pragma config OSC = INTIO67
#pragma config PWRT = ON, BOREN = SBORDIS, BORV = 3
#pragma config WDT = OFF
#pragma config MCLRE = ON, PBADEN = ON, CCP2MX = PORTC
#pragma config STVREN = ON, LVP = OFF

char tmp[5];
char valor;
unsigned char direccion = 0x48; // Direccion A0

unsigned char error;	

int temp;
int LDR;

int strlen(char string[])
{
    int i=0;
    while(string[i]!='\0') i++;
    return i;
}

void sendValor(int valor)
{
    char tmp[10];
    unsigned char len;
    int i=0;
    itoa(valor,tmp);
    len=strlen(tmp);
    for(i=0;i<len;i++)
    {
        while (PIR1bits.TXIF==0);
        WriteUSART(tmp[i]-48);
    }
}

void R_Int_Alta(void);  // Declaración de la subrutina de tratamiento de interrupciones de alta prioridad

// Retardos necesarios para el LCD
void DelayFor18TCY(void){Delay10TCYx(2);}	// Retardo de 18 ciclos
void DelayPORXLCD(void){Delay1KTCYx(15);}	// Retardo de 15ms
void DelayXLCD(void){Delay1KTCYx(5);}		// Retardo de 5ms

void ComandXLCD(unsigned char cmd)	// Funcion escritura comandos en LCD
{
    while (BusyXLCD());
    WriteCmdXLCD(cmd);
}

void gotoxyLCD(unsigned char x, unsigned char y)	// Funcion de posicionamiento
{
    unsigned char direccion;
    if (y!=1) direccion=0x40;	// Cada linea del display tiene 64 (40Hex) posiciones de las cuales solo se ven 16
    else direccion=0;
    direccion +=x-1;
    ComandXLCD(0x80|direccion);
}


#pragma code Vector_Int_Alta=0x08  // Vectorización de las interrupciones de alta prioridad
void Int_Alta (void)
{
    _asm GOTO R_Int_Alta _endasm
}
#pragma code

#pragma interrupt R_Int_Alta  // Rutina de tratamiento de las interrupciones de alta prioridad
void R_Int_Alta (void)
{

    if (INTCONbits.TMR0IF==1) // Se comprueba si la interrupción es por desbordamiento del temp. 0
    {
        INTCONbits.TMR0IF=0; // Se pone a 0 el flag de desbordamiento del temp. 0
        TMR0H=0x3C;				// Se carga el valor de TMR0H y TMR0L para un intervalo de 50ms
        TMR0L=0xB0;				// TMR0=65536-(TINTERVALO/TT0)=65536-(50e-3*4e6)/4)=15536=0x3CB0        
    }
    else if (PIR1bits.RCIF) // Se comprueba si la interrupción ha sido por recepción
    {
        char dato;
        dato = ReadUSART(); // Se almacena el dato leído en la posición correspondiente del bufer
        //putcXLCD(dato);
        if (dato=='1')
        {
            USART_SendValue_i(LDR);
            USART_SendValue_c(temp);
        }
    }

}
char lecturaLDR()
{
       
    
}
char lecturaI2C()
{
    static char value;
    error = 0;

    StartI2C();
    while(SSPCON2bits.SEN);

    WriteI2C(direccion*2);
    if (SSPCON2bits.ACKSTAT) error=1;	// Se activa el sensor correspondiente

    WriteI2C(0x00);		// Registro de temperatura
    if(SSPCON2bits.ACKSTAT) error=1;

    RestartI2C();
    while(SSPCON2bits.RSEN);

    WriteI2C(direccion*2|0x01);	// Se activa sensor paran lectura
    if(SSPCON2bits.ACKSTAT) error=1;

    value = ReadI2C();

    NotAckI2C();
    while(SSPCON2bits.ACKEN);

    StopI2C();
    while(SSPCON2bits.PEN);
    
  
    if (error)
    {
        return -100;
    }
    else
    {
        return value;
        /*itoa(valor,tmp); 
        putsXLCD(tmp);
        putcXLCD(0xdf); // Grados
        putrsXLCD("C");*/
    }
}

void main(void)		// Programa principal
{
    
    Delay10KTCYx(50);
    INTCONbits.GIE = 1; // Se activan las interrupciones a nivel global
    INTCONbits.PEIE = 1; // Se activan las interrupciones de periféricos a nivel global
    INTCONbits.TMR0IE=1; // Se habilita la interrupción del Temporizador 0
    PIE1bits.RCIE=1; // Se habilita la interrupción de recepción del canal serie
    
    OSCCONbits.IRCF0 = 0;
    OSCCONbits.IRCF1 = 1;
    OSCCONbits.IRCF2 = 1;
    
    ADCON0=0b00001101;
    ADCON1=0x0B;
    ADCON2=0xBC;
    
    
    OpenXLCD(FOUR_BIT & LINES_5X7); 	// Modo 4 bits, 5x7 puntos por caracter y dos líneas
    ComandXLCD(BLINK_OFF&CURSOR_OFF);	// Cursor y parpadeo apagados
   
    USART_Init();
   // Se configura la USART en modo 8 bits, sin paridad, 1 Stop bit, 9600 baud
   // e interr. de recepción habilitada
   // Vel. Com.= Fosc/(16*(SPBREG+1))=4000000/(16*(25+1))=9615
  
    /*T0CON=0x88;	// Timer 0 modo temp. de 16 bits. Prescalar desactivado. TIMER ON
    TMR0H=0x3C;	// Se carga el valor de TMR0H y TMR0L para un intervalo de 50ms
    TMR0L=0xB0;	// TMR0=65536-(TINTERVALO/TT0)=65536-(50e-3*4e6)/4)=15536=0x3CB0
    INTCONbits.GIE=1;	// Se habilitan las interrupciones a nivel global
    INTCONbits.TMR0IE=1; // Se habilita la interrupción del Temporizador 0*/
    
    OpenI2C(MASTER,SLEW_OFF);
    SSPADD = 9;

    gotoxyLCD(1,1);
    while(1)	// Bucle principal
    {
        temp=I2C_Read_c(direccion,0x00);
        ADCON0bits.GO=1;
        while(ADCON0bits.GO==1);
        LDR=ADRESH*256+ADRESL;
        gotoxyLCD(1,1); putrsXLCD("TEMP: ");
        itoa(temp,tmp);
        putsXLCD(tmp);
        putrsXLCD("   ");
        gotoxyLCD(1,2); putrsXLCD("LDR: ");
        itoa(LDR,tmp);
        putsXLCD(tmp);
        putrsXLCD("   ");
    }
}