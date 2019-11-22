/* 
 * File:   PIClib.h
 * Author: altorpon
 *
 * Created on 23 de octubre de 2019, 11:47
 */

#ifndef PICLIB_H
#define	PICLIB_H


#include <p18f4520.h>
#include <usart.h>
#include <i2c.h>

#ifdef	__cplusplus
extern "C" {
#endif

    void USART_SendValue_f(float value);
    void USART_SendValue_i(int value);
    void USART_SendValue_c(char value);
    void USART_Init();
    
    void I2C_Init();
    char I2C_Read_c(char dir,char cmd);

    

    
   
    
    
    


#ifdef	__cplusplus
}
#endif

#endif	/* PICLIB_H */

