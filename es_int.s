    ORG $0
    DC.L $8000 * Valor inicial del puntero de pila
    DC.L PPAL * Direccion RTI de la interrupcion Reset, etiqueta del programa ppal

    ORG $400

* Almacen de buffers

SIZE EQU 2001                   * Size de los buffers

    BUFF_V:     DC.L    0,0,0,0     * Punteros a los buffers

* extraccion, insercion, pos inicial, pos final 
    BUFF_0:     DC.L    0,0,0,0     * Buffer 0 -> Recepcion A
                DS.B    SIZE

    BUFF_1:     DC.L    0,0,0,0     * Buffer 1 -> Recepcion B
                DS.B    SIZE

    BUFF_2:     DC.L    0,0,0,0     * Buffer 2 -> Transmision A
                DS.B    SIZE

    BUFF_3:     DC.L    0,0,0,0     * Buffer 3 -> Transmision B
                DS.B    SIZE

    IMRCOPY:    DS.B    1            * Copia de IMR ya que no puede ser leido

* Registros de la DUART MC68681

MR1A	EQU		$EFFC01
MR2A	EQU		$EFFC01
SRA		EQU		$EFFC03
CSRA	EQU		$EFFC03
CRA		EQU		$EFFC05
TBA		EQU		$EFFC07
RBA		EQU		$EFFC07

ACR		EQU		$EFFC09
IMR		EQU		$EFFC0B
ISR		EQU		$EFFC0B

MR1B	EQU		$EFFC11
MR2B	EQU		$EFFC11
CRB     EQU     $effc15
TBB     EQU     $effc17
RBB     EQU     $effc17

SRB     EQU     $effc13
CSRB    EQU     $effc13
IVR		EQU		$EFFC19





    
    INIT:
        * Preparación de periféricos
                MOVE.B    #%00010000,CRA        * Reinicia el puntero MR1
                MOVE.B    #%00000011,MR1A       * 8 bits por caracter (interrumpe cada 8 bits)
                MOVE.B    #%00000000,MR2A       * Eco desactivado
                MOVE.B    #%11001100,CSRA       * Velocidad = 38400 bps

                MOVE.B    #%00010000,CRB        * Reinicia el puntero MR1
                MOVE.B    #%00000011,MR1B       * 8 bits por caracter (interrumpe cada 8 bits)
                MOVE.B    #%00000000,MR2B       * Eco desactivado
                MOVE.B    #%11001100,CSRB       * Velocidad = 38400 bps

                MOVE.B    #%00000000,ACR        * Velocidad = 38400 bps
                MOVE.B    #%00000101,CRA        * Transmision y recepcion activados
                MOVE.B    #%00000101,CRB        * Transmision y recepcion activados

                MOVE.B    #%00100010,IMRCOPY    * Copiar IMR en nuestra propia variable
                MOVE.B    IMRCOPY,IMR

                MOVE.B    #$40,IVR              * Vector de interrupcion = 64
                MOVE.L    #RTI,$100             * Decimal: 4*64 = 256 -> Hexa: 100


                * Mis propios inits

                MOVE.L    #BUFF_V,A0            * Vector de buffers 

                MOVE.L    #BUFF_0,(A0)          * Buffer recepcion A
                MOVE.L    #BUFF_1,4(A0)         * Buffer recepcion B
                MOVE.L    #BUFF_2,8(A0)         * Buffer transmision A
                MOVE.L    #BUFF_3,12(A0)        * Buffer transmision B

                * Inicializo todos los punteros de los buffers
                MOVE.L    #BUFF_0,A0            * Recepcion A
                MOVE.L    #BUFF_0+16,(A0)
                MOVE.L    #BUFF_0+16,4(A0)
                MOVE.L    #BUFF_0+16,8(A0)
                MOVE.L    #BUFF_0+SIZE+16,12(A0)

                MOVE.L    #BUFF_1,A0            * Recepcion B
                MOVE.L    #BUFF_1+16,(A0)
                MOVE.L    #BUFF_1+16,4(A0)
                MOVE.L    #BUFF_1+16,8(A0)
                MOVE.L    #BUFF_1+SIZE+16,12(A0)

                MOVE.L    #BUFF_2,A0            * Transmision A
                MOVE.L    #BUFF_2+16,(A0)
                MOVE.L    #BUFF_2+16,4(A0)
                MOVE.L    #BUFF_2+16,8(A0)
                MOVE.L    #BUFF_2+SIZE+16,12(A0)

                MOVE.L    #BUFF_3,A0            * Transmision B
                MOVE.L    #BUFF_3+16,(A0)
                MOVE.L    #BUFF_3+16,4(A0)
                MOVE.L    #BUFF_3+16,8(A0)
                MOVE.L    #BUFF_3+SIZE+16,12(A0)


                RTS

    *██╗     ███████╗███████╗ ██████╗ █████╗ ██████╗ *
  ***██║     ██╔════╝██╔════╝██╔════╝██╔══██╗██╔══██╗***
*****██║     █████╗  █████╗  ██║     ███████║██████╔╝*****
*****██║     ██╔══╝  ██╔══╝  ██║     ██╔══██║██╔══██╗*****
  ***███████╗███████╗███████╗╚██████╗██║  ██║██║  ██║***
    *╚══════╝╚══════╝╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝*

    LEECAR:     MOVEM.L A0-A2,-(A7)
                AND.L   #$3,D0
                ASL.L   #2,D0           * Get buffer seleccionado
                MOVE    #BUFF_V,A0      * Get vector de buffers
                MOVE.L  (A0,D0),A0      * Get buffer concreto
                MOVE.L  (A0),A1         * Get puntero de extraccion en A1
                MOVE.L  4(A0),A2        * Get puntero de insericon en A2

                EOR.L   D0,D0           * D0 = 0
                CMP.L   A1,A2           * Si extraccion e insercion son iguales -> empty buffer
                BEQ     EMPTY

                MOVE.B  (A1)+,D0        * Leo e incremento puntero
                CMP.L   12(A0),A1       * Si pos_final == p_extraccion -> final del buffer
                BEQ     E_RES

                MOVE.L  A1,(A0)         * Actualizo puntero de extraccion
                BRA     LC_END

    E_RES:      MOVE.L  8(A0),A1        * Extraccion reset
                MOVE.L  A1,(A0)
                BRA     LC_END

    EMPTY:      MOVE.L  #-1,D0          * Empty buffer

    LC_END:     MOVEM.L (A7)+,A0-A2     * Fin leecar
                RTS

    *███████╗███████╗ ██████╗ ██████╗ █████╗ ██████╗ *
  ***██╔════╝██╔════╝██╔════╝██╔════╝██╔══██╗██╔══██╗***
*****█████╗  ███████╗██║     ██║     ███████║██████╔╝*****
*****██╔══╝  ╚════██║██║     ██║     ██╔══██║██╔══██╗*****
  ***███████╗███████║╚██████╗╚██████╗██║  ██║██║  ██║***
    *╚══════╝╚══════╝ ╚═════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝*

    ESCCAR:     MOVEM.L A0-A2,-(A7)
                AND.L   #$3,D0
                ASL.L   #2,D0           * Get buffer seleccionado
                MOVE    #BUFF_V,A0      * Get vector de buffers
                MOVE.L  (A0,D0),A0      * Get buffer concreto
                MOVE.L  (A0),A1         * Get puntero de extraccion en A1
                MOVE.L  4(A0),A2        * Get puntero de insercion en A2

                MOVE.B  D1,(A2)+        * Insert caracter
                CMP.L   12(A0),A2       * Si pos_final == p_insercion -> final del buffer
                BNE     N_RES           * Si no esta en el final del buffer, continua en N_RES

                MOVE.L  8(A0),A2        * Reset del p_insercion

    N_RES:      CMP.L   A1,A2           * Si extraccion == insercion -> buffer full
                BEQ     FULL
                * No esta lleno
                MOVE.L  A2,4(A0)
                MOVE.L  #0,D0
                BRA     EC_END

    FULL:       MOVE.L  #-1,D0

    EC_END:      MOVEM.L (A7)+,A0-A2
                RTS

    *███████╗ ██████╗ █████╗ ███╗   ██╗*
  ***██╔════╝██╔════╝██╔══██╗████╗  ██║***
*****███████╗██║     ███████║██╔██╗ ██║*****
*****╚════██║██║     ██╔══██║██║╚██╗██║*****
  ***███████║╚██████╗██║  ██║██║ ╚████║***
    *╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝*

    SCAN:       LINK    A6,#0           * Los parametros de entrada estan 8B detras del puntero de pila
                MOVE.L  8(A6),A1        * A1 -> primer param (direccion del buffer destino)

                EOR.L   D0,D0
                MOVE.W  12(A6),D0       * D0 -> segundo param (descriptor del dispositivo sobre el que se lee)

                EOR.L   D1,D1
                MOVE.W  14(A6),D1       * D1 -> tercer param (size, num max de caracteres a copiar)

                EOR.L   D2,D2              * D2 -> retorno (contador de carcteres leidos)

                ***Seccion de deteccion de errores***
                CMP.W   #0,D1           * Si el size < 0 -> error (absurdo!)
                BLT     SC_ERR
                CMP.W   #1,D0           * Si el desc > 1 -> buffer desc incorrecto
                BGT     SC_ERR
                CMP.W   #0,D0           * Si el desc < 0 -> buffer desc incorrecto
                BLT     SC_ERR

    SC_BUF:     CMP.W   #0,D1
                BEQ     SC_OK           * Comprobamos si se han leido todos los caracteres
                MOVE.W  12(A6),D0        * Reseteamos el desc. del dispositivo sobre el que leer
                BSR     LEECAR
                CMP.L   #-1,D0          * Si empty buffer -> se va al final
                BEQ     SC_OK
                MOVE.B  D0,(A1)+        * Copiamos el caracter devuelto por leecar en la pos del buffer pasada
                SUB.W   #1,D1           * Size --
                ADD.L   #1,D2           * Contador ++
                BRA     SC_BUF

    SC_ERR:     MOVE.L  #-1,D0
                BRA     SC_END

    SC_OK:      MOVE.L  D2,D0

    SC_END:     UNLK    A6
                RTS

    *██████╗ ██████╗ ██╗███╗   ██╗████████╗*
  ***██╔══██╗██╔══██╗██║████╗  ██║╚══██╔══╝***
*****██████╔╝██████╔╝██║██╔██╗ ██║   ██║   *****
*****██╔═══╝ ██╔══██╗██║██║╚██╗██║   ██║   *****
  ***██║     ██║  ██║██║██║ ╚████║   ██║   ***
    *╚═╝     ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝   ╚═╝   *

    PRINT:      LINK  A6,#0             * Los parametros de entrada estan 8B detras del puntero de pila
                MOVE.L  8(A6),A1        * A1 -> primer param (direccion del buffer origen)

                EOR.L   D0,D0
                MOVE.W  12(A6),D0       * D0 -> segundo param (descriptor del dispositivo sobre el que se lee)
                * No se debe usar D1 ya que es un parametro de ESCCAR
                EOR.L   D2,D2 * Puede que no haga falta este
                MOVE.W  14(A6),D2       * D2 -> tercer param (size, num max de caracteres a copiar)

                EOR.L   D3,D3           * D3 -> retorno (contador de carcteres escritos)

                ***Seccion de deteccion de errores***
                CMP.W   #0,D2           * Si el size < 0 -> error (absurdo!)
                BLT     PR_ERR
                CMP.W   #1,D0           * Si el desc > 1 -> buffer desc incorrecto
                BGT     PR_ERR
                CMP.W   #0,D0           * Si el desc < 0 -> buffer desc incorrecto
                BLT     PR_ERR


    PR_BUF:     CMP.W   #0,D2
                BEQ     PR_MTX
                MOVE.W  12(A6),D0       * Reestablecemos el desc. del dispositivo sobre el que escribir
                ADD.W   #2,D0           * Para obtener el descriptor del buffer interno 2 = trans A, 3 = trans B
                EOR.L   D1,D1 * Puede que esta linea sobre
                MOVE.B  (A1)+,D1
                BSR     ESCCAR          * Params: D0 -> desc (2+X para X = 0 e 1), D1 -> buff pointer
                CMP.L   #-1,D0          * Si empty buffer -> se va al final
                BEQ     PR_MTX
                SUB.W   #1,D2           * Size --
                ADD.L   #1,D3           * Contador ++
                BRA     PR_BUF

    PR_MTX:     CMP.L   #0,D3
                BEQ     PR_OK           * Si no se escribe nada, no es necesario hacer gestion mutex
                MOVE.W  SR,D4           * Salvamos SR (status register)
                * Puede crearse una variable global con valor $2700
                MOVE.W  #$2700,SR       *  Inhibir interrupciones
                * Para dejar en T Ready la linea A, necesitamos activar el bit 0
                * Para dejar en T Ready la linea B, necesitamos activar el bit 4
                * Si multiplicamos 4 por el descriptor de entrada (0 e 1) tenemos el bit que deseamos de IMR
                MOVE.W  12(A6),D2
                MULU    #4,D2
                BSET    D2,IMR
                BSET    D2,IMRCOPY           
                MOVE.W  D4,SR           * Restauramos SR (status register)

    PR_OK:      MOVE.L  D3,D0           * D3 (ret -> num car escritos) MV a D0
                BRA     PR_END

    PR_ERR:     MOVE.L  #-1,D0

    PR_END:     UNLK    A6
                RTS
              


    RTI:        RTE




PPAL: * Manejadores de excepciones
    MOVE.L  #BUS_ERROR,8     * Bus error handler
    MOVE.L  #ADDRESS_ER,12   * Address error handler
    MOVE.L  #ILLEGAL_IN,16   * Illegal instruction handler
    MOVE.L  #PRIV_VIOLT,32   * Privilege Violation handler

    BSR     INIT

***************************************
*██╗  ██╗██╗████████╗ ██████╗      ██╗*
*██║  ██║██║╚══██╔══╝██╔═══██╗    ███║*
*███████║██║   ██║   ██║   ██║    ╚██║*
*██╔══██║██║   ██║   ██║   ██║     ██║*
*██║  ██║██║   ██║   ╚██████╔╝     ██║*
*╚═╝  ╚═╝╚═╝   ╚═╝    ╚═════╝      ╚═╝*
***************************************
                                     

*** Prueba 2: Llamada a ESCCAR introduciendo un caracter en el buffer de recepción de la línea A (0)
***
*************************************************************************************************************************
**
*pr02es_int:
*    MOVE.L #0,D0
*    MOVE.L #1,D1
*    BSR ESCCAR      * D0 tiene que ser 0
    *BRA COMPCOR
*************************************************************************************************************************
**
*** Prueba 3: Se escriben 10 caracteres en el buffer de recepción de la linea B(1) (10 llamadas a ESCCAR).
***
*************************************************************************************************************************
**
*pr03es_int:
*    MOVE.L #10,D3
*    MOVE.L #1,D7
*    BSR BUCESN1S
    *BRA COMPCOR    * D0 tiene que ser 0
*************************************************************************************************************************
**
*** Prueba 4: Se escriben 300 caracteresen el buffer de transmisión de la linea A (2) (300 llamadas a ESCCAR).
***
*************************************************************************************************************************
**
*pr04es_int:
*    MOVE.L #2,D7
*    MOVE.L #300,D3
*    BSR BUCESNFF
    *BRA COMPCOR    * D0 tiene que ser 0

*************************************************************************************************************************
**
*** Prueba 5: Se escriben 2000 caracteresen el buffer de transmisión de la linea B (3) (2000 llamadas a ESCCAR).
***
*************************************************************************************************************************
**
*pr05es_int:
*    MOVE.L #2000,D3
*    MOVE.L #3,D7
*    BSR BUCESNFF
    *BRA COMPCOR    * D0 tiene que ser 0
*************************************************************************************************************************
**
*** Prueba 6: Se escriben más de 2000 caracteresen el buffer de transmisión de la linea B (3) (2001 llamadas a ESCCAR). ***
*************************************************************************************************************************
**
*pr06es_int:
*    MOVE.L #2000,D3
*    MOVE.L #3,D7
*    BSR BUCESNFF
*    MOVE.L #3,D0
*    MOVE.L #11,D1 * caracter 2001
*    BSR ESCCAR
*    *BRA COMPF      * D0 tiene que ser -1
*************************************************************************************************************************
**
*** Prueba 7: Se prueba a leer un caracter de un buffer vacío (LEECAR buffer recepcion línea A)
*****
*************************************************************************************************************************
**
*pr07es_int:
*    MOVE.L #0,D0
*    BSR LEECAR
    *BRA COMPF      * D0 tiene que ser -1 
*************************************************************************************************************************
**


*** Prueba 8: Se prueba a leer un caracter con 200 escritos en el buffer (LEECAR buffer recepcion línea A(0))
***
*************************************************************************************************************************
**
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
*************************************************************************************************************************
**
*** Prueba 9: Se prueba a leer 10 caracteres con 300 escritos en el buffer (LEECAR buffer recepcion línea B(1))
***
*************************************************************************************************************************
**
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

*************************************************************************************************************************
**
*** Prueba 10: Se prueba a leer 300 caracteres con 300 escritos en el buffer (LEECAR buffer transmisión línea A(2)) ***
*************************************************************************************************************************
**
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


*************************************************************************************************************************
**
*** Prueba 11: Se realiza la inserción de 2000 caracteres en el buffer interno de transmisión de la linea B(3) llamando ***
*** sucesivamente a ESCCAR. A continuación se leen 2000 caracteres de dicho buffer llamando a LEECAR
***
*************************************************************************************************************************
**
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

*************************************************************************************************************************
**
*************************************************************************************************************************
**
*** Prueba 12: Se realiza la inserción de 1800 caracteres en el buffer interno de recepcion de la linea A(0) llamando ***
*** sucesivamente a ESCCAR. A continuación se leen 100 caracteres de dicho buffer llamando a LEECAR y se vuelven a
***
*** insertar 300 caracteres.
***
*************************************************************************************************************************
**
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
    * BRA COMPCOR       *D0 tiene que ser 0


*************************************************************************************************************************
**
*** Prueba 13: Se realiza la inserción de 2000 caracteres en el buffer interno de recepcion de la linea B(1) llamando ***
*** sucesivamente a ESCCAR. A continuación se lee 1 caracter de dicho buffer llamando a LEECAR y se vuelven a insertar ***
*** 2 caracteres.
***
*************************************************************************************************************************
**
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

*************************************************************************************************************************
**
*** Prueba 14: Se realiza la inserción de 2000 caracteres en el buffer interno de transmisión de la linea A(2) llamando ***
*** sucesivamente a ESCCAR. A continuación se lee 10 caracteres de dicho buffer llamando a LEECAR y se vuelven a
***
*** insertar 10 caracteres y por último se vuelven a leer 2000.
***
*************************************************************************************************************************
**
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

*************************************************************************************************************************
**
*** Prueba 15: Se realiza la inserción de 2000 caracteres en el buffer interno de transmisión de la linea B(3) llamando ***
*** sucesivamente a ESCCAR. A continuación se leen 1000 caracteres de dicho buffer llamando a LEECAR y se vuelven a ***
*** insertar 1000 caracteres y por último se vuelven a leer 1500.
***
*************************************************************************************************************************
**
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


************************************
*███████╗ ██████╗ █████╗ ███╗   ██╗*
*██╔════╝██╔════╝██╔══██╗████╗  ██║*
*███████╗██║     ███████║██╔██╗ ██║*
*╚════██║██║     ██╔══██║██║╚██╗██║*
*███████║╚██████╗██║  ██║██║ ╚████║*
*╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝*
************************************

*** Prueba scan 1: inserta 100 caracteres en el buffer interno de recepcion de la linea A (0)
*** se leen 100. Resultado esperado -> D0 = 64 (100 en hex)

p_scan_1:
    MOVE.L  #$100,D3
    MOVE.L  #0,D7
    BSR     BUCESNFF
    MOVE.W  #$100,-(A7)
    MOVE.W  #0,-(A7)
    MOVE.L  #$5000,-(A7)
    BSR     SCAN
    CMP.L   #$100,D0
    BNE     AMENTET

*** Prueba scan 2: inserta 100 caracteres en el buffer interno de recepcion de la linea B (1)
*** se leen 25 caracteres 4 veces de tal manera que el buffer quede vacio. Resultado esperado:
*** D0 = 19 (25 en hex). Pos $50FF en memoria = pos $D01
                                  
p_scan_2:
            MOVE.L  #$94,D3         * 25 * 4 es 94 en hex
            MOVE.L  #1,D7
            BSR    BUCESNFF
            MOVE.L  #0,D4
p_s_2_b:    CMP.L   #4,D4
            BEQ     p_s_2_e
            MOVE.W  #$25,-(A7)
            MOVE.W  #1,-(A7)
            MOVE.L  #$5000,-(A7)
            BSR     SCAN
            CMP.L   #$25,D0
            BNE     AMENTET
            ADD.L   #1,D4
            BRA     p_s_2_b
p_s_2_e:    MOVE.L  D3,D4


*** Prueba scan 3: inserta 10 caracteres y se intenta leer 20 en el buffer interno de recepcion A (0)
*** El resultado esperado es 10 en D0 y guardar desde 00 hasta 09 en la posicion $5000 de memoria
p_scan_3:   MOVE.L  #10,D3
            MOVE.L  #0,D7
            BSR     BUCESNFF
            MOVE.W  #20,-(A7)
            MOVE.W  #0,-(A7)
            MOVE.L  #$5000,-(A7)
            BSR     SCAN
            CMP.L   #10,D0
            BNE     AMENTET
            MOVE.L  D3,D4

    *██████╗ ██████╗ ██╗███╗   ██╗████████╗*
  ***██╔══██╗██╔══██╗██║████╗  ██║╚══██╔══╝***
*****██████╔╝██████╔╝██║██╔██╗ ██║   ██║   *****
*****██╔═══╝ ██╔══██╗██║██║╚██╗██║   ██║   *****
  ***██║     ██║  ██║██║██║ ╚████║   ██║   ***
    *╚═╝     ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝   ╚═╝   *

p_prt_1:
            MOVE.L  #$100,D3
            MOVE.L  #3,D7
            BSR     BUCESNFF
            MOVE.W  #$100,-(A7)
            MOVE.W  #1,-(A7)
            MOVE.L  #$5000,-(A7)
            BSR     PRINT
            CMP.L   #$100,D0
            BNE     AMENTET
            MOVE.L  D3,D4
            

*********************************************************
* █████╗ ██╗   ██╗██╗  ██╗██╗██╗     ██╗ █████╗ ██████╗ *
*██╔══██╗██║   ██║╚██╗██╔╝██║██║     ██║██╔══██╗██╔══██╗*
*███████║██║   ██║ ╚███╔╝ ██║██║     ██║███████║██████╔╝*
*██╔══██║██║   ██║ ██╔██╗ ██║██║     ██║██╔══██║██╔══██╗*
*██║  ██║╚██████╔╝██╔╝ ██╗██║███████╗██║██║  ██║██║  ██║*
*╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝╚══════╝╚═╝╚═╝  ╚═╝╚═╝  ╚═╝*
*********************************************************

* La rutina AMENTET hace referencia a la diosa egipcia homonima la cual era la patrona de las puertas
* del inframundo en el que esperaba a los difuntos que no superaban las pruebas en su camino al paraiso.
* En este caso, las subrutinas que no superen las pruebas, las esperara AMENTET que para indicar su fallo
* y mandarlas corregir.
AMENTET:
            MOVE.L  #-1,D0
            MOVE.L  #-1,D1
            MOVE.L  #-1,D2
            MOVE.L  #-1,D3
            MOVE.L  #-1,D4
            MOVE.L  #-1,D5
            MOVE.L  #-1,D6
            MOVE.L  #-1,D7
            MOVE.L  #-1,A0
            MOVE.L  #-1,A1
            MOVE.L  #-1,A2
            MOVE.L  #-1,A3
            MOVE.L  #-1,A4
            MOVE.L  #-1,A5
            BREAK
                                                       
*************************************************************************************************************************
*****
*** Funcionamiento de los bucles:
***
*** -D7 es el buffer que queremos usar: D7={0,1,2,3}, por lo tanto hay que hacer un MOVE.L #X,D7, donde x es el buffer ***
*** -La variable n es D3, por lo tanto si queremos meter 200 numeros por ejemplo hay que hacer MOVE.L #200,D3
***
*************************************************************************************************************************
*****
*************************************************************************************************************************
*****
*** Este bucle llama a ESCCAR n veces rellenando el buffer todo con unos
***
BUCESN1S:
    EOR D4,D4 *Contador de elementos
    buc1:
        MOVE.L #1,D1 *Variable 1 que queremos meter en el buffer n veces
        MOVE.L D7,D0
        BSR ESCCAR
        ADD.L #1,D4
        CMP.L D3,D4
        BNE buc1
    RTS



*************************************************************************************************************************
*****
*************************************************************************************************************************
*****
*** Este bucle llama a ESCCAR n veces rellenando el buffer todo con números desde 0 al FF en hexadecimal
***
BUCESNFF:
    EOR D4,D4
    EOR D1,D1
    buc2:
        MOVE.L D7,D0
        BSR ESCCAR
        ADD.L #1,D4
        ADD.L #1,D1
        CMP.L #$100,D1
        BEQ D1ZERO
        BRA FINB1
        D1ZERO: EOR D1,D1
        FINB1: CMP.L D3,D4
        BNE buc2
    RTS




*************************************************************************************************************************
*****
*************************************************************************************************************************
*****
*** Este bucle llama a ESCCAR n veces rellenando el buffer todo con números desde 0 al 9 en hexadecimal
***
BUCESN09:
    EOR D4,D4
    EOR D1,D1
    buc4:
        MOVE.L D7,D0
        BSR ESCCAR
        ADD.L #1,D4
        ADD.L #1,D1
        CMP.L #10,D1
        BEQ D1ZERO2
        BRA FINB12
        D1ZERO2: EOR D1,D1
        FINB12: CMP.L D3,D4
        BNE buc4
    RTS


*************************************************************************************************************************
*** Este bucle llama a LEECAR n veces
***
BUCLEEN:
    EOR D4,D4
    buc3:
        MOVE.L D7,D0
        BSR LEECAR
        ADD.L #1,D4
        CMP.L D3,D4
        BNE buc3
    RTS

COMPCOR: CMP.L #0,D0
    BEQ BIEN
    BRA MAL

COMPF: CMP #-1,D0
    BEQ BIEN
    BRA MAL

BIEN: MOVE.L #$abcdef10,D5
    BRA FINC

MAL: MOVE.L #-1,D5

FINC: BREAK


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