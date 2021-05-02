ORG $0
DC.L $8000 * Valor inicial del puntero de pila
DC.L $PPAL * Direccion RTI de la interrupcion Reset, etiqueta del programa ppal

ORG $400

SIZE EQU 2001

LEECAR:     MOVEM.L A0-A2
            AND.L   #3,DO  
            CMP.L   #0,D0
            BEQ     LEECAR0
            CMP.L   #1,D0
            BEQ     LEECAR1
            CMP.L   #2,D0
            BEQ     LEECAR2

LEECAR3:    MOVE.L  #PEXT3,A0   * Guardo en A0 la direccion de la etiqueta PEXT3
            MOVE.L  (A0),A1     * Guardo en A1 el puntero de extraccion del buffer 3
            MOVE.L  (A0),A2     * Guardo en A2 el puntero de insercion del buffer 3
            MOVE.L  #FIN3,A0
            MOVE.L  (A0),A3
            BRA     SIGUE

LEECAR0:    MOVE.L  #PEXT0,A0   * Guardo en A0 la direccion de la etiqueta PEXT3
            MOVE.L  (A0),A1     * Guardo en A1 el puntero de extraccion del buffer 3
            MOVE.L  (A0),A2     * Guardo en A2 el puntero de insercion del buffer 3
            MOVE.L  #FIN0,A0
            MOVE.L  (A0),A3
            BRA     SIGUE

LEECAR1:    MOVE.L  #PEXT1,A0   * Guardo en A0 la direccion de la etiqueta PEXT3
            MOVE.L  (A0),A1     * Guardo en A1 el puntero de extraccion del buffer 3
            MOVE.L  (A0),A2     * Guardo en A2 el puntero de insercion del buffer 3
            MOVE.L  #FIN1,A0
            MOVE.L  (A0),A3
            BRA     SIGUE

LEECAR2:    MOVE.L  #PEXT2,A0   * Guardo en A0 la direccion de la etiqueta PEXT3
            MOVE.L  (A0),A1     * Guardo en A1 el puntero de extraccion del buffer 3
            MOVE.L  (A0),A2     * Guardo en A2 el puntero de insercion del buffer 3
            MOVE.L  #FIN2,A0
            MOVE.L  (A0),A3

SIGUE:      EOR.L   D0,D0       * D0 = 0
            CMP.L   A1,A2       * Si los dos punteros apuntan al mismo sitio, el buffer esta vacio
            BEQ     VACIO
            MOVE.B  (A1)+,D0
            CMP.L   A3,A1       * Comprobamos si estamos al final del buffer
            BEQ     INICIALIZA



* Bufferes
ORG $5000

BUFFER0: DS.B SIZE  * Recepcion linea A
BUFFER1: DS.B SIZE  * Recepcion linea B
BUFFER2: DS.B SIZE  * Transmision linea A
BUFFER3: DS.B SIZE  * Transmision linea B

PEXT0:      DC.L BUFFER0        * Puntero de extraccion del buffer 0
PINS0:      DC.L BUFFER0        * Puntero de insercion del buffer 0
INI0:       DC.L BUFFER0        * Posicion inicial del buffer 0
FIN0:       DC.L BUFFER0 + SIZE * Posicion final del buffer 0

PEXT1:      DC.L BUFFER1        * Puntero de extraccion del buffer 1
PINS1:      DC.L BUFFER1        * Puntero de insercion del buffer 1
INI1:       DC.L BUFFER1        * Posicion inicial del buffer 1
FIN1:       DC.L BUFFER1 + SIZE * Posicion final del buffer 1

PEXT2:      DC.L BUFFER2        * Puntero de extraccion del buffer 2
PINS2:      DC.L BUFFER2        * Puntero de insercion del buffer 2
INI2:       DC.L BUFFER2        * Posicion inicial del buffer 2
FIN2:       DC.L BUFFER2 + SIZE * Posicion final del buffer 2

PEXT3:      DC.L BUFFER3        * Puntero de extraccion del buffer 3
PINS3:      DC.L BUFFER3        * Puntero de insercion del buffer 3
INI3:       DC.L BUFFER3        * Posicion inicial del buffer 3
FIN3:       DC.L BUFFER3 + SIZE * Posicion final del buffer 3
