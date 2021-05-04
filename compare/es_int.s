	ORG		$0
	DC.L	$8000	*Valor inicial puntero pila
	DC.L 	PPAL	*Dirección RTI de la interrupción Reset, etiqueta del programa principal
	
	ORG		$400
	
	TAMANO	EQU	2001
	
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
	CRB     EQU     $effc15       * de control A (escritura)
	TBB     EQU     $effc17       * buffer transmision B (escritura)
	RBB     EQU     $effc17       * buffer recepcion B (lectura)
	SRB     EQU     $effc13       * de estado B (lectura)
	CSRB    EQU     $effc13       * de seleccion de reloj B (escritura)
	IVR		EQU		$EFFC19



	INIT:   MOVE.B          #%00010000,CRA      * Reinicia el puntero MR1		
			MOVE.B          #%00000011,MR1A     * 8 bits por caracter.
			MOVE.B          #%00000000,MR2A     * Eco desactivado.
			MOVE.B          #%11001100,CSRA     * Velocidad = 38400 bps.
			
			MOVE.B          #%00010000,CRB      * Reinicia el puntero MR1		
			MOVE.B          #%00000011,MR1B     * 8 bits por caracter.
			MOVE.B          #%00000000,MR2B     * Eco desactivado.
			MOVE.B          #%11001100,CSRB     * Velocidad = 38400 bps.
			
			MOVE.B          #%00000000,ACR      * Velocidad = 38400 bps.
			MOVE.B          #%00000101,CRA      * Transmision y recepcion activados.
			MOVE.B          #%00000101,CRB      * Transmision y recepcion activados.
			
			MOVE.B 			#$40,IVR			* Vector de interrupción 40
			
			MOVE.B			#%00100010,COPIAIMR
			MOVE.B			#%00100010,IMR
			
			MOVE.L 			#RTI,$100			* Pongo en la TV la dirección de la RTI (4*IVR=4*$40=4*64=256=$100)
			
			MOVE.L 			#BUFFER0,PEXT0	* Valor inicial de PEXT0 es la dirección de la etiqueta BUFFER0, q es donde empieza el buffer
			MOVE.L 			#BUFFER0,PINS0
			MOVE.L 			#BUFFER0,INI0
			MOVE.L			#BUFFER0+TAMANO,FIN0
			
			MOVE.L 			#BUFFER1,PEXT1
			MOVE.L 			#BUFFER1,PINS1
			MOVE.L 			#BUFFER1,INI1
			MOVE.L			#BUFFER1+TAMANO,FIN1
			
			MOVE.L 			#BUFFER2,PEXT2
			MOVE.L 			#BUFFER2,PINS2
			MOVE.L 			#BUFFER2,INI2
			MOVE.L			#BUFFER2+TAMANO,FIN2
			
			MOVE.L 			#BUFFER3,PEXT3
			MOVE.L 			#BUFFER3,PINS3
			MOVE.L 			#BUFFER3,INI3
			MOVE.L			#BUFFER3+TAMANO,FIN3
			
			RTS
			
	SCAN:	LINK	A6,#0	*Inicializo marco de pila pero sin abrir hueco, únicamente para referenciar los datos en la pila
			MOVE.L 	8(A6),A1	*Guardo en A1 la dirección de Buffer
			CLR.L 	D2		*MOVE.L	#0,D2
			CLR.L 	D3
			CLR.L 	D4		*Contador de caracteres leídos, lo inicializamos a 0
			MOVE.W	12(A6),D2	*Guardo el descriptor en D2
			MOVE.W	14(A6),D3	*Guardo el tamaño en D3
			CMP.W	#0,D2
			BEQ		SCANA
			CMP.W	#1,D2
			BEQ		SCANB
			MOVE.L 	#$FFFFFFFF,D0	*Si llegamos aquí hay error en los parámetros
			BRA		FINSCAN
			
	SCANA:	CLR.L 	D0	*Ponemos D0=0 para la llamada a LEECAR (lectura de la línea A)
			BSR		LEECAR
			CMP.L	#-1,D0	*Si D0=-1, no hay caracteres disponibles para leer, así que hemos terminado
			BEQ		FINSCAN1
			MOVE.B	D0,(A1)+	*Copiamos el carácter a la dirección del Buffer que nos pasan
			ADD.L 	#1,D4		*Incrementamos en 1 el contador de caracteres
			SUB.W	#1,D3		*Decrementamos en 1 el tamaño a leer
			CMP.W	#0,D3
			BNE		SCANA
			BRA		FINSCAN1
			
	SCANB:	MOVE.L 	#1,D0	*Ponemos D0=1 para la llamada a LEECAR (buffer de recepción de la línea B)
			BSR		LEECAR
			CMP.L	#-1,D0	*Si D0=-1, no hay caracteres disponibles para leer, así que hemos terminado
			BEQ		FINSCAN1
			MOVE.B	D0,(A1)+	*Copiamos el carácter a la dirección del Buffer que nos pasan
			ADD.L 	#1,D4		*Incrementamos en 1 el contador de caracteres
			SUB.W	#1,D3		*Decrementamos en 1 el tamaño a leer
			CMP.W	#0,D3
			BNE		SCANB
			BRA		FINSCAN1
			
	FINSCAN1:	MOVE.L 	D4,D0	*Copiamos los caracteres leídos a D0
	FINSCAN:	UNLK	A6
				RTS
				
	PRINT:	LINK	A6,#0		*Inicializo marco de pila pero sin abrir hueco, únicamente para referenciar los datos en la pila
			MOVE.L 	8(A6),A1	*Guardo en A1 la dirección de Buffer
			CLR.L	D2			*MOVE.L #0,D2
			CLR.L 	D3
			CLR.L 	D4			*Contador de caracteres escritos, lo inicializamos a 0
			MOVE.W	12(A6),D2	*Guardo en D2 el descriptor
			MOVE.W	14(A6),D3	*Guardo en D3 el tamaño
			CMP.W	#0,D2
			BEQ		PRINTA		*Si el descriptor es 0 es la línea A
			CMP.W	#1,D2
			BEQ		PRINTB		*Si el descriptor es 1 es la línea B
			MOVE.L	#$FFFFFFFF,D0	*Si estamos aquí hay un error en los parámetros
			BRA		FINPRINT
			
	PRINTA:	MOVE.L 	#2,D0
			CMP.W	#0,D3		*Para ver si nos quedan caracteres para imprimir
			BEQ		FINPRINA
			MOVE.B 	(A1)+,D1
			BSR		ESCCAR
			CMP.L 	#-1,D0		*Para ver si el buffer interno está lleno
			BEQ		FINPRINA
			ADD.L	#1,D4		*Sumamos 1 al contador de caracteres escritos
			SUB.W	#1,D3		*Restamos 1 al tamaño (contador de caracteres que quedan por escribir)
			BRA		PRINTA
			
	PRINTB:	MOVE.L 	#3,D0
			CMP.W	#0,D3		*Para ver si nos quedan caracteres para imprimir
			BEQ		FINPRINB
			MOVE.B 	(A1)+,D1
			BSR		ESCCAR
			CMP.L 	#-1,D0		*Para ver si el buffer interno está lleno
			BEQ		FINPRINB
			ADD.L	#1,D4		*Sumamos 1 al contador de caracteres escritos
			SUB.W	#1,D3		*Restamos 1 al tamaño (contador de caracteres que quedan por escribir)
			BRA		PRINTB
			
	FINPRINA:	CMP.L 	#0,D4		*Para ver si se ha copiado algún carácter en el buffer interno
				BEQ		FINPRIN2	*Si no se han copiado caracteres no hay que activar las interrupciones de transmisión
				MOVE.W	SR,D5		*Guardo en D5 el valor actual del registro de estado (para saber cómo están las interrupciones ahora)
				MOVE.W	#$2700,SR	*Inhibo las interrupciones un momento pq voy a habilitar las interrupciones de transmisión de línea A (evitar excl. mutua)
				BSET	#0,COPIAIMR
				BSET	#0,IMR
				MOVE.W	D5,SR		*Termina la zona de exclusión mutua, restauro el estado anterior de las interrupciones
				BRA		FINPRIN2
				
	FINPRINB:	CMP.L 	#0,D4		*Para ver si se ha copiado algún carácter en el buffer interno
				BEQ		FINPRIN2	*Si no se han copiado caracteres no hay que activar las interrupciones de transmisión
				MOVE.W	SR,D5		*Guardo en D5 el valor actual del registro de estado (para saber cómo están las interrupciones ahora)
				MOVE.W	#$2700,SR	*Inhibo las interrupciones un momento pq voy a habilitar las interrupciones de transmisión de línea A (evitar excl. mutua)
				BSET	#4,COPIAIMR
				BSET	#4,IMR
				MOVE.W	D5,SR		*Termina la zona de exclusión mutua, restauro el estado anterior de las interrupciones
	
	FINPRIN2:	MOVE.L 	D4,D0		*En D0 se devuelven los caracteres copiados

	FINPRINT:	UNLK	A6
				RTS
		
	RTI:		MOVEM.L D0-D1,-(A7)
	BUCLE1:		MOVE.B 	ISR,D1
				AND.B	COPIAIMR,D1
				BTST	#1,D1	*Recepción línea A
				BNE		RXLA
				BTST 	#5,D1	*Recepción línea B
				BNE		RXLB
				BTST	#0,D1	*Transmisión línea A
				BNE		TXLA
				BTST	#4,D1	*Transmisión línea B
				BNE		TXLB
				BRA		FINRTI
				
	RXLA:		MOVE.B 	RBA,D1
				MOVE.L 	#0,D0
				BSR 	ESCCAR
				CMP.L 	#-1,D0
				BEQ		FINRTI	*Si está lleno el buffer terminamos
				BRA		BUCLE1
				
	RXLB:		MOVE.B 	RBB,D1
				MOVE.L 	#1,D0
				BSR 	ESCCAR
				CMP.L 	#-1,D0
				BEQ		FINRTI	*Si está lleno el buffer terminamos
				BRA		BUCLE1
				
	TXLA:		MOVE.L 	#2,D0
				BSR		LEECAR
				CMP.L 	#-1,D0
				BEQ		INHA
				MOVE.B 	D0,TBA
				BRA 	BUCLE1
		
	INHA:		BCLR	#0,COPIAIMR
				BCLR	#0,IMR
				BRA		BUCLE1
				
	TXLB:		MOVE.L 	#3,D0
				BSR		LEECAR
				CMP.L 	#-1,D0
				BEQ		INHB
				MOVE.B 	D0,TBB
				BRA 	BUCLE1
		
	INHB:		BCLR	#4,COPIAIMR
				BCLR	#4,IMR
				BRA		BUCLE1
				
	FINRTI:		MOVEM.L	(A7)+,D0-D1
				RTE
	
	
	LEECAR:		MOVEM.L A0-A2,-(A7)
				AND.L	#3,D0
				CMP.L	#0,D0
				BEQ		LEECAR0
				CMP.L 	#1,D0
				BEQ		LEECAR1
				CMP.L 	#2,D0
				BEQ		LEECAR2
	LEECAR3:	MOVE.L 	#PEXT3,A0	*Guardo en A0 la dirección de la etiqueta PEXT3
				MOVE.L 	(A0),A1		*Guardo en A1 el puntero de extracción del buffer 3
				MOVE.L 	4(A0),A2	*Guardo en A2 el puntero de inserción del buffer 3
				BRA		SIGUE
	LEECAR0:	MOVE.L 	#PEXT0,A0	
				MOVE.L 	(A0),A1		 
				MOVE.L 	4(A0),A2
				BRA		SIGUE			
	LEECAR1:	MOVE.L 	#PEXT1,A0	
				MOVE.L 	(A0),A1		 
				MOVE.L 	4(A0),A2
				BRA		SIGUE
	LEECAR2:	MOVE.L 	#PEXT2,A0	
				MOVE.L 	(A0),A1		 
				MOVE.L 	4(A0),A2
	SIGUE:		EOR.L	D0,D0		*D0=0
				CMP.L 	A1,A2		*Si los 2 punteros apuntan al mismo sitio, el buffer está vacío
				BEQ		VACIO
				MOVE.B 	(A1)+,D0	*Leo el carácter y postincremento el puntero a la siguiente posición
				CMP.L 	12(A0),A1	*Miramos si estamos al final del buffer
				BEQ		INICIALIZA
				MOVE.L 	A1,(A0)		*Actualizo el valor del puntero de extracción en memoria
				BRA		FINLC
	INICIALIZA:	MOVE.L 	8(A0),A1
				MOVE.L 	A1,(A0)		*Actualizo el valor del puntero de extracción en memoria
				BRA		FINLC
	VACIO:		MOVE.L 	#-1,D0
	FINLC:		MOVEM.L (A7)+,A0-A2
				RTS
				
	ESCCAR:		MOVEM.L A0-A2,-(A7)
				AND.L	#3,D0
				CMP.L	#0,D0
				BEQ		ESCCAR0
				CMP.L 	#1,D0
				BEQ		ESCCAR1
				CMP.L 	#2,D0
				BEQ		ESCCAR2
	ESCCAR3:	MOVE.L 	#PEXT3,A0	*Guardo en A0 la dirección de la etiqueta PEXT3
				MOVE.L 	(A0),A1		*Guardo en A1 el puntero de extracción del buffer 3
				MOVE.L 	4(A0),A2	*Guardo en A2 el puntero de inserción del buffer 3
				BRA		SIGUE1
	ESCCAR0:	MOVE.L 	#PEXT0,A0	
				MOVE.L 	(A0),A1		 
				MOVE.L 	4(A0),A2
				BRA		SIGUE1			
	ESCCAR1:	MOVE.L 	#PEXT1,A0	
				MOVE.L 	(A0),A1		 
				MOVE.L 	4(A0),A2
				BRA		SIGUE1
	ESCCAR2:	MOVE.L 	#PEXT2,A0	
				MOVE.L 	(A0),A1		 
				MOVE.L 	4(A0),A2
	SIGUE1:		MOVE.B	D1,(A2)+
				CMP.L	12(A0),A2	*Si son iguales estamos al final del buffer y hay que inicializar el puntero de inserción
				BEQ		INICIO1
	SIGUE2:		CMP.L	A1,A2		*Si son iguales, es que el buffer está lleno
				BNE		NOLLENO
				MOVE.L 	#-1,D0		*Si está lleno ponemos D0=-1
				BRA		FINEC
	INICIO1:	MOVE.L 	8(A0),A2
				BRA		SIGUE2
	NOLLENO:	MOVE.L 	A2,4(A0)	*Actualizamos el puntero de inserción en memoria
				MOVE.L 	#0,D0		*D0=0 para indicar que hemos tenido éxito (también se puede poner EOR.L D0,D0)
	FINEC:		MOVEM.L (A7)+,A0-A2
	
				*A0=M(A7)
				*A7=A7+4
				*A1=M(A7)
				*A7=A7+4
				*A2=M(A7)
				*A7=A7+4
				
				RTS

	PPAL:		MOVE.L #BUS_ERROR,8 * Bus error handler
				MOVE.L #ADDRESS_ER,12 * Address error handler
				MOVE.L #ILLEGAL_IN,16 * Illegal instruction handler
				MOVE.L #PRIV_VIOLT,32 * Privilege violation handler
				MOVE.L #ILLEGAL_IN,40 * Illegal instruction handler
				MOVE.L #ILLEGAL_IN,44 * Illegal instruction handler
				
				BSR INIT
				
				MOVE.L 	#1,D0	*D0=1 (Rx Línea B)
				MOVE.B  $41,D1
				BSR 	ESCCAR
				
				MOVE.L 	#1,D0
				BSR 	LEECAR	*Si todo va bien, en D0 deberíamos tener $41
				
				MOVE.L 	#2002,D2
	BUCLE:		MOVE.L 	#1,D0	*D0=1 (Rx Línea B)
				MOVE.B  $41,D1
				BSR 	ESCCAR
				SUB.L 	#1,D2	
				CMP.L 	#0,D2
				BNE		BUCLE	*Cuando salga del bucle, el valor de D0 debería ser -1, pq ya está lleno el buffer
				
	BUS_ERROR: 	BREAK * Bus error handler
				NOP
	ADDRESS_ER: BREAK * Address error handler
				NOP
	ILLEGAL_IN: BREAK * Illegal instruction handler
				NOP
	PRIV_VIOLT: BREAK * Privilege violation handler
				NOP
				


	ORG		$5000
	
	BUFFER0:	DS.B 	TAMANO	*Recepción línea A
	BUFFER1:	DS.B	TAMANO	*Recepción línea B 
	BUFFER2:	DS.B 	TAMANO	*Transmisión línea A
	BUFFER3:	DS.B 	TAMANO	*Transmisión línea B	
	
	PEXT0:		DC.L 	BUFFER0	*Puntero de extracción del buffer 0
	PINS0:		DC.L 	BUFFER0	*Puntero de inserción del buffer 0
	INI0:		DC.L	BUFFER0	*Posición inicial del buffer 0
	FIN0:		DC.L 	BUFFER0+TAMANO	*Posición final del buffer 0
	
	PEXT1:		DC.L 	BUFFER1	*Puntero de extracción del buffer 1
	PINS1:		DC.L 	BUFFER1	*Puntero de inserción del buffer 1
	INI1:		DC.L	BUFFER1	*Posición inicial del buffer 1
	FIN1:		DC.L 	BUFFER1+TAMANO	*Posición final del buffer 1
	
	PEXT2:		DC.L 	BUFFER2	*Puntero de extracción del buffer 2
	PINS2:		DC.L 	BUFFER2	*Puntero de inserción del buffer 2
	INI2:		DC.L	BUFFER2	*Posición inicial del buffer 2
	FIN2:		DC.L 	BUFFER2+TAMANO	*Posición final del buffer 2
	
	PEXT3:		DC.L 	BUFFER3	*Puntero de extracción del buffer 3
	PINS3:		DC.L 	BUFFER3	*Puntero de inserción del buffer 3
	INI3:		DC.L	BUFFER3	*Posición inicial del buffer 3
	FIN3:		DC.L 	BUFFER3+TAMANO	*Posición final del buffer 3
	
	COPIAIMR:	DS.B 	1
	
	