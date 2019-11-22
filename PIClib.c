#include "PIClib.h"

void USART_Init()
{
    OpenUSART (USART_TX_INT_OFF & USART_RX_INT_ON & 
             USART_ASYNCH_MODE & USART_EIGHT_BIT & 
             USART_CONT_RX & USART_BRGH_HIGH,25);
}
void USART_SendValue_f(float value)
{
    ;
}
void USART_SendValue_i(int value)
{
    //LOW BYTE
    while (PIR1bits.TXIF==0);
    WriteUSART(value%256);
    //HIGH BYTE
    while (PIR1bits.TXIF==0);
    WriteUSART(value/256);
}
void USART_SendValue_c(char value)
{
    while (PIR1bits.TXIF==0);
    WriteUSART(value);
}

char I2C_Read_c(char dir,char cmd)
{
    static char value;
    static char error=0;

    StartI2C();
    while(SSPCON2bits.SEN);

    WriteI2C(dir*2);
    if (SSPCON2bits.ACKSTAT) error=1;	// Se activa el sensor correspondiente

    WriteI2C(cmd);		// Registro de temperatura
    if(SSPCON2bits.ACKSTAT) error=1;

    RestartI2C();
    while(SSPCON2bits.RSEN);

    WriteI2C(dir*2|0x01);	// Se activa sensor paran lectura
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