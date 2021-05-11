</br></br></br></br></br></br></br></br>

# <p style="text-align: center;">Proyecto de Arquitectura de Computadores</br>Sistemas de Entrada/Salida</p>

<p style="text-align: center;">Curso 2020/2021</p>

</br></br></br></br></br></br></br></br>

## Informacion

| Informacion del proyecto: |  |   
| ----------- | --------
| Titulación  | Grado de Ingeniería Informática. Plan 09.
| Curso         | 2020/21
| Asignatura     | Arquitectura de Computadores
| Curso		 | 2º Curso
| Semestre    | 5º Semestre
| Proyecto    | Proyecto Entrada/Salida
<br><br>

## Autores
- Sara Sanchez Mota [180423]
- Francisco Javier Serrano Arrese [180487]



## Indice
Aqui va el indice


## Aspectos generales

<div style="text-align: justify">El proyecto consiste en controlar el manejo de operaciones de Entrada/Salida en un periferico mediante interrupciones. El dispositivo elegido es la DUART MC68681 operando ambas lineas mediante interrupciones. En el computador del proyecto la DUART esta conectada a la linea de peticion de interrupcion de nivel 4.</div>
</br>
<div style="text-align: justify">El diagrama de flujo del proyecto se muestra mas adelante en la seccion homonima "Diagrama de flujo". Como puede apreciarse se necesitan unos bufferes internos para almacenar los caracteres que se reciben asincronamente por las lineas. Del mismo modo, se necesitan sendos bufferes internos para almacenar los caracteres pendientes de transmitirse por las lineas.</div>
</br>
<div style="text-align: justify">Se cuenta con 4 bufferes en total, 2 de recepcion (BUFF_0 y BUFF_1) y otros 2 de transmision (BUFF_2 y BUFF_3). Estos bufferes son de tipo circular y hacen uso de un byte extra de tipo burbuja para asegurar su correcto funcionamiento. Las direcciones de estos bufferes en memoria estan contenidas en un vector de direcciones de bufferes denominado buffer vector (BUFFER_V). Cada buffer cuenta a su vez con dos punteros de manejeo, uno de insercion y otro de extraccion junto con dos punteros de posicion en memoria, uno de inicio y otro de final. Los dos ultimos tinen un proposito meramente de debugging.</div>
</br>
<div style="text-align: justify">Ademas, existe una unica rutina de tratamiento de las interrupciones de las lineas que sera la encargada transferir la informacion a o desde los mencionados bufferes internos. El proyecto implica la porgramacion de la rutina de tratamiento de las interrupciones (RTI) junto con las subrutinas INIT, SCAN, PRINT, LEECAR y ESCCAR cuyas caracteristicas de desarrollaran detalladamente en la seccion "Subrutinas".</div>
</br>
<div style="text-align: justify">Por ultimo aclarar ciertos detalles del proyecto. En primer lugar, se empieza la codificacion a partir de la direccion de memoria $400 y el puntero de pila es descendente y comienza en la direccion $8000. A su vez, la direccion para almacenar datos en memoria para las pruebas es la $5000 y es creciente. Los bufferes internos ocupan 2017 (2000 B de datos, 1 B burbuja, 16 B punteros), estos bufferes estan comprendidos entre las posiciones $410 y $2397. Por ultimo aclarar que se hace una copia del IMR denominada IMRCOPY debido a que no se puede leer directamente de este, y las direcciones de las lineas a y b son EFFC07 y EFFC17 respectivamente.</div>


## Diagrama de flujo








### ASCII Fonts

https://manytools.org/hacker-tools/ascii-banner/

    - Big ASCII font: DOS Rebel
    - Small ASCII font: ANSI Shadow
