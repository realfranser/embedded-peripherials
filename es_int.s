    ORG     $0
    DC.L    $8000           * Pila
    DC.L    INICIO          * PC
    
***************************************************************************
*   █████████     ███████    ██████████   █████   █████████     ███████   *
*  ███░░░░░███  ███░░░░░███ ░░███░░░░███ ░░███   ███░░░░░███  ███░░░░░███ *
* ███     ░░░  ███     ░░███ ░███   ░░███ ░███  ███     ░░░  ███     ░░███*
*░███         ░███      ░███ ░███    ░███ ░███ ░███         ░███      ░███*
*░███         ░███      ░███ ░███    ░███ ░███ ░███    █████░███      ░███*
*░░███     ███░░███     ███  ░███    ███  ░███ ░░███  ░░███ ░░███     ███ *
* ░░█████████  ░░░███████░   ██████████   █████ ░░█████████  ░░░███████░  *
*  ░░░░░░░░░     ░░░░░░░    ░░░░░░░░░░   ░░░░░   ░░░░░░░░░     ░░░░░░░    *
***************************************************************************
    ORG     $400
    
TAMANYO EQU     2000          * Buffer para escritura y lectura de caracteres

MR1A    EQU     $effc01       * de modo A (escritura)
MR2A    EQU     $effc01       * de modo A (2º escritura)
SRA     EQU     $effc03       * de estado A (lectura)
CSRA    EQU     $effc03       * de seleccion de reloj A (escritura)
CRA     EQU     $effc05       * de control A (escritura)
TBA     EQU     $effc07       * buffer transmision A (escritura)
RBA     EQU     $effc07       * buffer recepcion A  (lectura)

MR1B    EQU     $effc11       * de modo B (escritura)
MR2B    EQU     $effc11       * de modo B (2º escritura)
SRB     EQU     $effc13       * de estado B (lectura)
CSRB    EQU     $effc13       * de seleccion de reloj B (escritura)
CRB     EQU     $effc15       * de control B (escritura)
TBB     EQU     $effc17       * buffer transmision B (escritura)
RBB     EQU     $effc17       * buffer recepcion B  (lectura)

ACR     EQU     $effc09       * de control auxiliar
IMR     EQU     $effc0B       * de mascara de interrupcion ambas (escritura)
ISR     EQU     $effc0B       * de estado de interrupcion de ambas (lectura)
IVR     EQU     $effc19       * vector de interrupccion de AMBAS


***************************
*██╗███╗   ██╗██╗████████╗*
*██║████╗  ██║██║╚══██╔══╝*
*██║██╔██╗ ██║██║   ██║   *
*██║██║╚██╗██║██║   ██║   *
*██║██║ ╚████║██║   ██║   *
*╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝   *
***************************

    INIT:
        MOVE.L    #V,A0        * Vector de buffers internos

        MOVE.L    #V0,(A0)
        MOVE.L    #V1,4(A0)
        MOVE.L    #V2,8(A0)
        MOVE.L    #V3,12(A0)
        
        * Preparación de periféricos
        MOVE.B    #%00010000,CRA      * Reinicia el puntero MR1
        MOVE.B    #%00000011,MR1A     * Solicita interrupccion por cada caracter. 8 bits por caracter
        MOVE.B    #%00000000,MR2A     * Eco desactivado.
        MOVE.B    #%11001100,CSRA     * Velocidad = 38400 bps.
        MOVE.B    #%00000000,ACR      * Velocidad = 38400 bps.
        MOVE.B    #%00000101,CRA      * Transmision y recepcion activados.

        MOVE.B    #%00010000,CRB      * Reinicia el puntero MR1
        MOVE.B    #%00000011,MR1B     * Solicita interrupccion por cada caracter. 8 bits por caracter.
        MOVE.B    #%00000000,MR2B     * Eco desactivado.
        MOVE.B    #%11001100,CSRB     * Velocidad = 38400 bps.
        MOVE.B    #%00000101,CRB      * Transmision y recepcion activados.

        *MOVE.B    #%00100010,IMRCOPY  * Permitir interrupción de recepción
        *MOVE.B    IMRCOPY,IMR

        *MOVE.L    #RTI,$100           * 256 = 64 * 4
        MOVE.B    #$40,IVR            * Vector de interrupcion = 64
        
        * MOVE.W    #$2000,SR           * Permite interrupciones
        RTS


**************************************************
*██╗     ███████╗███████╗ ██████╗ █████╗ ██████╗ *
*██║     ██╔════╝██╔════╝██╔════╝██╔══██╗██╔══██╗*
*██║     █████╗  █████╗  ██║     ███████║██████╔╝*
*██║     ██╔══╝  ██╔══╝  ██║     ██╔══██║██╔══██╗*
*███████╗███████╗███████╗╚██████╗██║  ██║██║  ██║*
*╚══════╝╚══════╝╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝*
**************************************************
    LEECAR:
        * Selección de buffer
        AND.L   #$3,D0
        ASL.L   #2,D0
        MOVE.L  #V,A0
        MOVE.L  (A0,D0),A0
                
        *Comprobación de buffer vacío
        CMP     #0,4(A0)
        BEQ     b_vacio
        
        MOVE    (A0),D1
        MOVE.B  8(A0,D1),D0
        
        *Actualización de variables
        ADD     #1,(A0)      * Incrementa "inicio"
        MOVE    SR,D7                                  * Inicio seccion crítica
        MOVE    #$2700,SR                              * Inicio seccion critica
        SUB     #1,4(A0)     * Decrementa "tamanyo"    *
        MOVE    D7,SR                                  * Fin sección crítica

        *Comprobamos que inicio no se pasa de 2000 
        CMP     #2000,(A0)
        BLT     modLee
        SUB     #2000,(A0)

        modLee:                                        
        CMP 0,D0 
        BEQ lee_recA
        CMP 1,D0
        BEQ lee_recB
        CMP 2,D0
        BEQ lee_traA
        CMP 3,D0
        BEQ lee_traB
        RTS

        lee_recA:
            MOVE 0,RBA
            BEQ ret_lee
        lee_recB:
            MOVE 0,RBB
            BEQ ret_lee
        lee_traA:
            MOVE 0,TBA
            BEQ ret_lee
        lee_traB:
            MOVE 0,TBB
            BEQ ret_lee
        
        ret_lee:
            MOVE 0,D0
            RTS

        b_vacio:
            MOVE.L  #-1,D0
            RTS
        
**************************************************
*███████╗███████╗ ██████╗ ██████╗ █████╗ ██████╗ *
*██╔════╝██╔════╝██╔════╝██╔════╝██╔══██╗██╔══██╗*
*█████╗  ███████╗██║     ██║     ███████║██████╔╝*
*██╔══╝  ╚════██║██║     ██║     ██╔══██║██╔══██╗*
*███████╗███████║╚██████╗╚██████╗██║  ██║██║  ██║*
*╚══════╝╚══════╝ ╚═════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝*
**************************************************
                                                

    ESCCAR:
        * Selección de buffer
        AND.L   #$3,D0
        ASL.L   #2,D0
        MOVE    #V,A0
        MOVE.L  (A0,D0),A0
        
        * Comprobación de buffer lleno
        CMP     #2000,4(A0)
        BEQ     b_lleno

        MOVE    2(A0),D2
        MOVE.B  D1,8(A0,D2)
        
        * Actualización de variables
        ADD     #1,2(A0)   * Incrementar "fin"         
        MOVE    SR,D7                                  * Inicio Sección crítica
        MOVE    #$2700,SR                              * Inicio Sección crítica
        ADD     #1,4(A0)   * Incrementar "tamano"      *
        MOVE    D7,SR                                  * Fin sección crítica

        *Comprobamos que fin no se pasa de 2000        
        CMP     #2000,2(A0)                            
        BLT     modEsc                                 
        SUB     #2000,2(A0)                            
                                                       
        modEsc:                                        
        CMP 0,D0 
        BEQ es_recA
        CMP 1,D0
        BEQ es_recB
        CMP 2,D0
        BEQ es_traA
        CMP 3,D0
        BEQ es_traB
        RTS

        es_recA:
            MOVE D1,RBA
            BEQ ret_es
        es_recB:
            MOVE D1,RBB
            BEQ ret_es
        es_traA:
            MOVE D1,TBA
            BEQ ret_es
        es_traB:
            MOVE D1,TBB
            BEQ ret_es
        
        ret_es:
            MOVE 0,D0
            RTS

        b_lleno:
            MOVE.L  #-1,D0
            RTS
        

************************************
*███████╗ ██████╗ █████╗ ███╗   ██╗*
*██╔════╝██╔════╝██╔══██╗████╗  ██║*
*███████╗██║     ███████║██╔██╗ ██║*
*╚════██║██║     ██╔══██║██║╚██╗██║*
*███████║╚██████╗██║  ██║██║ ╚████║*
*╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝*
************************************


    SCAN:
        AND.L #$3,D0

****************************************
*██████╗ ██████╗ ██╗███╗   ██╗████████╗*
*██╔══██╗██╔══██╗██║████╗  ██║╚══██╔══╝*
*██████╔╝██████╔╝██║██╔██╗ ██║   ██║   *
*██╔═══╝ ██╔══██╗██║██║╚██╗██║   ██║   *
*██║     ██║  ██║██║██║ ╚████║   ██║   *
*╚═╝     ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝   ╚═╝   *
****************************************
                                      
    PRINT:
        AND.L #$3,D0
                                          
    RTI:
        AND.L #$3,D0
*******************************************************************************
*   REGIÓN DE VARIABLES GLOBALES
********************************************************************************
    V:      DC.L   0,0,0,0
    IMRCOPY:DC.B   0

********************************************************************************
*   REGIÓN DE HEAP
********************************************************************************
    ORG     $1000

*
    V0:     DC.W   0,0,0,0
            DS.B   TAMANYO
    V1:     DC.W   0,0,0,0
            DS.B   TAMANYO
    V2:     DC.W   0,0,0,0
            DS.B   TAMANYO
    V3:     DC.W   0,0,0,0
            DS.B   TAMANYO

********************************************************************************************
*███████████  ███████████   █████  █████ ██████████ ███████████    █████████    █████████  *
*░░███░░░░░███░░███░░░░░███ ░░███  ░░███ ░░███░░░░░█░░███░░░░░███  ███░░░░░███  ███░░░░░███*
* ░███    ░███ ░███    ░███  ░███   ░███  ░███  █ ░  ░███    ░███ ░███    ░███ ░███    ░░░ *
* ░██████████  ░██████████   ░███   ░███  ░██████    ░██████████  ░███████████ ░░█████████ *
* ░███░░░░░░   ░███░░░░░███  ░███   ░███  ░███░░█    ░███░░░░░███ ░███░░░░░███  ░░░░░░░░███*
* ░███         ░███    ░███  ░███   ░███  ░███ ░   █ ░███    ░███ ░███    ░███  ███    ░███*
* █████        █████   █████ ░░████████   ██████████ ███████████  █████   █████░░█████████ *
*░░░░░        ░░░░░   ░░░░░   ░░░░░░░░   ░░░░░░░░░░ ░░░░░░░░░░░  ░░░░░   ░░░░░  ░░░░░░░░░  *
********************************************************************************************

    ORG     $4000

BUFFER: DS.B    2100   * Buffer para escritura y lectura de caracteres
CONTL:  DC.W    0      * Contador de lineas
CONTC:  DC.W    0      * Contador de caracteres
DIRLEC: DC.L    0      * Direccion de lectura para SCAN
DIRESC: DC.L    0      * Direccion de lectura para PRINT
TAME:   DC.L    0      * Tamano de escritura para print
DESA:   EQU     0      * Descriptor linea A
DESB:   EQU     1      * Descriptor linea B

NLIN:   EQU     15     * Numero de lineas a leer
TAML:   EQU     100    * Tamano de linea para SCAN
TAMB:   EQU     5      * Tamano de bloque para PRINT
    
    
INICIO: * Manejadores de excepciones
    MOVE.L  #BUS_ERROR,8     * Bus error handler
    MOVE.L  #ADDRESS_ER,12   * Address error handler
    MOVE.L  #ILLEGAL_IN,16   * Illegal instruction handler
    MOVE.L  #PRIV_VIOLT,32   * Privilege Violation handler

    BSR     INIT
*    MOVE.L    #V,A0        * Vector de buffers internos
*
*    MOVE.L    #V0,(A0)
*    MOVE.L    #V1,4(A0)
*    MOVE.L    #V2,8(A0)
*    MOVE.L    #V3,12(A0)
*
*
***************************************************
**██╗     ███████╗███████╗ ██████╗ █████╗ ██████╗ *
**██║     ██╔════╝██╔════╝██╔════╝██╔══██╗██╔══██╗*
**██║     █████╗  █████╗  ██║     ███████║██████╔╝*
**██║     ██╔══╝  ██╔══╝  ██║     ██╔══██║██╔══██╗*
**███████╗███████╗███████╗╚██████╗██║  ██║██║  ██║*
**╚══════╝╚══════╝╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝*
***************************************************
*
**** Prueba 2: Llamada a ESCCAR introduciendo un caracter en el buffer de recepción de la línea A (0)
****
**************************************************************************************************************************
***
*pr02es_int:
*    MOVE.L #0,D0
*    MOVE.L #1,D1
*    BSR ESCCAR
*    BRA COMPCOR
**************************************************************************************************************************
***
**** Prueba 3: Se escriben 10 caracteres en el buffer de recepción de la linea B(1) (10 llamadas a ESCCAR).
****
**************************************************************************************************************************
***
*pr03es_int:
*    MOVE.L #10,D3
*    MOVE.L #1,D7
*    BSR BUCESN1S
*    BRA COMPCOR
**************************************************************************************************************************
***
**** Prueba 4: Se escriben 300 caracteresen el buffer de transmisión de la linea A (2) (300 llamadas a ESCCAR).
****
**************************************************************************************************************************
***
*pr04es_int:
*    MOVE.L #2,D7
*    MOVE.L #300,D3
*    BSR BUCESNFF
*    BRA COMPCOR
*
**************************************************************************************************************************
***
**** Prueba 5: Se escriben 2000 caracteresen el buffer de transmisión de la linea B (3) (2000 llamadas a ESCCAR).
****
**************************************************************************************************************************
***
*pr05es_int:
*    MOVE.L #2000,D3
*    MOVE.L #3,D7
*    BSR BUCESNFF
*    BRA COMPCOR
**************************************************************************************************************************
***
**** Prueba 6: Se escriben más de 2000 caracteresen el buffer de transmisión de la linea B (3) (2001 llamadas a ESCCAR). ***
**************************************************************************************************************************
***
*pr06es_int:
*    MOVE.L #2000,D3
*    MOVE.L #3,D7
*    BSR BUCESNFF
*    MOVE.L #3,D0
*    MOVE.L #11,D1 * caracter 2001
*    BSR ESCCAR
*    BRA COMPF
**************************************************************************************************************************
***
**** Prueba 7: Se prueba a leer un caracter de un buffer vacío (LEECAR buffer recepcion línea A)
****
**************************************************************************************************************************
***
*pr07es_int:
*    MOVE.L #0,D0
*    BSR LEECAR
*    BRA COMPF
**************************************************************************************************************************
***
*
*
**** Prueba 8: Se prueba a leer un caracter con 200 escritos en el buffer (LEECAR buffer recepcion línea A(0))
****
**************************************************************************************************************************
***
*pr08es_int:
*    MOVE.L #200,D3
*    MOVE.L #0,D7
*    BSR BUCESNFF
*    MOVE.L #0,D0
*    BSR LEECAR
*    CMP.L #0,D0
*    BEQ BIEN
*    MOVE.L #-1,D5
*    BRA FINC
**************************************************************************************************************************
***
**** Prueba 9: Se prueba a leer 10 caracteres con 300 escritos en el buffer (LEECAR buffer recepcion línea B(1))
****
**************************************************************************************************************************
***
*pr09es_int:
*    MOVE.L #200,D3
*    MOVE.L #1,D7
*    BSR BUCESNFF
*    MOVE.L #1,D7
*    MOVE.L #10,D3
*    BSR BUCLEEN
*    CMP.L #$9,D0
*    BEQ BIEN
*    MOVE.L #-1,D5
*    BRA FINC
*
**************************************************************************************************************************
***
**** Prueba 10: Se prueba a leer 300 caracteres con 300 escritos en el buffer (LEECAR buffer transmisión línea A(2)) ***
**************************************************************************************************************************
***
*pr10es_int:
*    MOVE.L #300,D3
*    MOVE.L #2,D7
*    BSR BUCESNFF
*    MOVE.L #2,D7
*    MOVE.L #300,D3
*    BSR BUCLEEN
*    CMP.L #$2B,D0
*    BEQ BIEN
*    MOVE.L #-1,D5
*    BRA FINC
*
*
***************************************************
**███████╗███████╗ ██████╗ ██████╗ █████╗ ██████╗ *
**██╔════╝██╔════╝██╔════╝██╔════╝██╔══██╗██╔══██╗*
**█████╗  ███████╗██║     ██║     ███████║██████╔╝*
**██╔══╝  ╚════██║██║     ██║     ██╔══██║██╔══██╗*
**███████╗███████║╚██████╗╚██████╗██║  ██║██║  ██║*
**╚══════╝╚══════╝ ╚═════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝*
***************************************************
*
**************************************************************************************************************************
***
**** Prueba 11: Se realiza la inserción de 2000 caracteres en el buffer interno de transmisión de la linea B(3) llamando ***
**** sucesivamente a ESCCAR. A continuación se leen 2000 caracteres de dicho buffer llamando a LEECAR
****
**************************************************************************************************************************
***
*pr11es_int:
*    MOVE.L #2000,D3
*    MOVE.L #3,D7
*    BSR BUCESNFF
*    MOVE.L #3,D7
*    MOVE.L #2000,D3
*    BSR BUCLEEN
*    CMP.L #$CF,D0
*    BEQ BIEN
*    MOVE.L #-1,D5
*    BRA FINC
*
**************************************************************************************************************************
***
**************************************************************************************************************************
***
**** Prueba 12: Se realiza la inserción de 1800 caracteres en el buffer interno de recepcion de la linea A(0) llamando ***
**** sucesivamente a ESCCAR. A continuación se leen 100 caracteres de dicho buffer llamando a LEECAR y se vuelven a
****
**** insertar 300 caracteres.
****
**************************************************************************************************************************
***
*pr12es_int:
*    MOVE.L #1800,D3
*    MOVE.L #0,D7
*    BSR BUCESNFF
*    MOVE.L #0,D7
*    MOVE.L #100,D3
*    BSR BUCLEEN
*    MOVE.L #300,D3
*    MOVE.L #0,D7
*    BSR BUCESNFF
*    BRA COMPCOR
*
*
**************************************************************************************************************************
***
**** Prueba 13: Se realiza la inserción de 2000 caracteres en el buffer interno de recepcion de la linea B(1) llamando ***
**** sucesivamente a ESCCAR. A continuación se lee 1 caracter de dicho buffer llamando a LEECAR y se vuelven a insertar ***
**** 2 caracteres.
****
**************************************************************************************************************************
***
*pr13es_int:
*    MOVE.L #2000,D3
*    MOVE.L #1,D7
*    BSR BUCESNFF
*    MOVE.L #1,D0
*    MOVE.L #1,D1
*    BSR LEECAR
*    MOVE.L #2,D3
*    MOVE.L #1,D7
*    BSR BUCESNFF
*    BRA COMPF
*
**************************************************************************************************************************
***
**** Prueba 14: Se realiza la inserción de 2000 caracteres en el buffer interno de transmisión de la linea A(2) llamando ***
**** sucesivamente a ESCCAR. A continuación se lee 10 caracteres de dicho buffer llamando a LEECAR y se vuelven a
****
**** insertar 10 caracteres y por último se vuelven a leer 2000.
****
**************************************************************************************************************************
***
*pr14es_int:
*    MOVE.L #2000,D3
*    MOVE.L #2,D7
*    BSR BUCESNFF
*    MOVE.L #2,D7
*    MOVE.L #10,D3
*    BSR BUCLEEN
*    MOVE.L #10,D3
*    MOVE.L #2,D7
*    BSR BUCESNFF
*    MOVE.L #2,D7
*    MOVE.L #2000,D3
*    BSR BUCLEEN
*    CMP.L #$9,D0
*    BEQ BIEN
*    MOVE.L #-1,D5
*    BRA FINC
*
**************************************************************************************************************************
***
**** Prueba 15: Se realiza la inserción de 2000 caracteres en el buffer interno de transmisión de la linea B(3) llamando ***
**** sucesivamente a ESCCAR. A continuación se leen 1000 caracteres de dicho buffer llamando a LEECAR y se vuelven a ***
**** insertar 1000 caracteres y por último se vuelven a leer 1500.
****
**************************************************************************************************************************
***
*pr15es_int:
*    MOVE.L #2000,D3
*    MOVE.L #3,D7
*    BSR BUCESNFF
*    MOVE.L #3,D7
*    MOVE.L #1000,D3
*    BSR BUCLEEN
*    MOVE.L #1000,D3
*    MOVE.L #3,D7
*    BSR BUCESNFF
*    MOVE.L #3,D7
*    MOVE.L #1500,D3
*    BSR BUCLEEN
*    CMP.L #$F3,D0
*    BEQ BIEN
*    MOVE.L #-1,D5
*    BRA FINC
*
**********************************************************
** █████╗ ██╗   ██╗██╗  ██╗██╗██╗     ██╗ █████╗ ██████╗ *
**██╔══██╗██║   ██║╚██╗██╔╝██║██║     ██║██╔══██╗██╔══██╗*
**███████║██║   ██║ ╚███╔╝ ██║██║     ██║███████║██████╔╝*
**██╔══██║██║   ██║ ██╔██╗ ██║██║     ██║██╔══██║██╔══██╗*
**██║  ██║╚██████╔╝██╔╝ ██╗██║███████╗██║██║  ██║██║  ██║*
**╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝╚══════╝╚═╝╚═╝  ╚═╝╚═╝  ╚═╝*
*********************************************************
*                                                       
**************************************************************************************************************************
******
**** Funcionamiento de los bucles:
****
**** -D7 es el buffer que queremos usar: D7={0,1,2,3}, por lo tanto hay que hacer un MOVE.L #X,D7, donde x es el buffer ***
**** -La variable n es D3, por lo tanto si queremos meter 200 numeros por ejemplo hay que hacer MOVE.L #200,D3
****
**************************************************************************************************************************
******
**************************************************************************************************************************
******
**** Este bucle llama a ESCCAR n veces rellenando el buffer todo con unos
****
*BUCESN1S:
*    EOR D4,D4 *Contador de elementos
*    buc1:
*        MOVE.L #1,D1 *Variable 1 que queremos meter en el buffer n veces
*        MOVE.L D7,D0
*        BSR ESCCAR
*        ADD.L #1,D4
*        CMP.L D3,D4
*        BNE buc1
*    RTS
*
*
*
**************************************************************************************************************************
******
**************************************************************************************************************************
******
**** Este bucle llama a ESCCAR n veces rellenando el buffer todo con números desde 0 al FF en hexadecimal
****
*BUCESNFF:
*    EOR D4,D4
*    EOR D1,D1
*    buc2:
*        MOVE.L D7,D0
*        BSR ESCCAR
*        ADD.L #1,D4
*        ADD.L #1,D1
*        CMP.L #$100,D1
*        BEQ D1ZERO
*        BRA FINB1
*        D1ZERO: EOR D1,D1
*        FINB1: CMP.L D3,D4
*        BNE buc2
*    RTS
*
*
*
*
**************************************************************************************************************************
******
**************************************************************************************************************************
******
**** Este bucle llama a ESCCAR n veces rellenando el buffer todo con números desde 0 al 9 en hexadecimal
****
*BUCESN09:
*    EOR D4,D4
*    EOR D1,D1
*    buc4:
*        MOVE.L D7,D0
*        BSR ESCCAR
*        ADD.L #1,D4
*        ADD.L #1,D1
*        CMP.L #10,D1
*        BEQ D1ZERO2
*        BRA FINB12
*        D1ZERO2: EOR D1,D1
*        FINB12: CMP.L D3,D4
*        BNE buc4
*    RTS
*
*
**************************************************************************************************************************
**** Este bucle llama a LEECAR n veces
****
*BUCLEEN:
*    EOR D4,D4
*    buc3:
*        MOVE.L D7,D0
*        BSR LEECAR
*        ADD.L #1,D4
*        CMP.L D3,D4
*        BNE buc3
*    RTS
*
*COMPCOR: CMP.L #0,D0
*    BEQ BIEN
*    BRA MAL
*
*COMPF: CMP #-1,D0
*    BEQ BIEN
*    BRA MAL
*
*BIEN: MOVE.L #$abcdef10,D5
*    BRA FINC
*
*MAL: MOVE.L #-1,D5
*
*FINC: BREAK
*
*
** Given by guide
**
**INICIO: * Manejadores de excepciones
**    MOVE.L  #BUS_ERROR,8     * Bus error handler
**    MOVE.L  #ADDRESS_ER,12   * Address error handler
**    MOVE.L  #ILLEGAL_IN,16   * Illegal instruction handler
**    MOVE.L  #PRIV_VIOLT,32   * Privilege Violation handler
**
**    BSR     INIT
**    MOVE.W  #$2000,SR        * Permite interrupciones
**
**BUCPR:
**    MOVE.W  #0,CONTC         * Inicializa contador de caracteres
**    MOVE.W  #NLIN,CONTL      * Inicializa contador de lineas
**    MOVE.L  #BUFFER,DIRLEC   * Direccion de lectura = comienzo del buffer
**
**OTRAL:
**    MOVE.W  #TAML,-(A7)      * Tamano maximo de la linea
**    MOVE.W  #DESB,-(A7)      * Puerto A
**    MOVE.L  DIRLEC,-(A7)     * Direccion de lectura
**
**ESPL:
**    BSR     SCAN
**    CMP.L   #0,D0
**    BEQ     ESPL             * Si no se ha leido la linea, se intenta de nuevo
**    ADD.L   #8,A7            * Reestablece la pila
**    ADD.L   D0,DIRLEC        * Calcula la nueva direccion de lectura
**    ADD.W   D0,CONTC         * Actualiza el contador de caracteres
**
**    SUB.W   #1,CONTL         * Actualiza el numero de lineas leidas.
**    BNE     OTRAL            * Si no se han leido todas, se vuelve a leer
**
**    MOVE.L  #BUFFER,DIRLEC   * DIreccion de lectura = comienzo del buffer
**
**OTRAE:
**    MOVE.W  #TAMB,TAME       * Tamano de escritura = tamano de bloque
**
**ESPE:
**    MOVE.W  TAME,-(A7)       * Tamano de escritura
**        MOVE.W  #DESA,-(A7)      * Puerto B
**        MOVE.L  DIRLEC,-(A7)     * Direccion de lectura
**    * BREAK
**    BSR     PRINT
**    ADD.L   #8,A7            * Reestablece la pila
**    ADD.L   D0,DIRLEC        * Calcula la nueva direccion del buffer
**    SUB.W   D0,CONTC         * Actualiza el contador de caracteres
**    BEQ     SALIR            * Si no quedan caracteres, se acaba
**    SUB.W   D0,TAME          * Actualiza el tamano de escritura
**    BNE     ESPE             * Si no se ha escrito todo el bloque, se insiste
**    CMP.W   #TAMB,CONTC      * Si el numero de caracteres restantes es menor que el establecido, se transmite ese numero
**    BHI     OTRAE            * Siguiente bloque
**    MOVE.W  CONTC,TAME
**    BRA     ESPE             * Siguiente bloque
**
**SALIR:
**    BRA     BUCPR
**
**FIN:
**    BREAK
**
**BUS_ERROR:
**    BREAK                    * Bus error handler
**    NOP
**
**ADDRESS_ER:
**    BREAK                    * Address error handler
**    NOP
**
**ILLEGAL_IN:
**    BREAK                    * Illegal instruction handler
**    NOP
**
**PRIV_VIOLT:
**    BREAK                    * Priviledge violation handler
**    NOP
**

BUS_ERROR:
    BREAK                    * Bus error handler
    NOP

ADDRESS_ER:
    BREAK                    * Address error handler
    NOP

ILLEGAL_IN:
    BREAK                    * Illegal instruction handler
    NOP

PRIV_VIOLT:
    BREAK                    * Priviledge violation handler
    NOP
*