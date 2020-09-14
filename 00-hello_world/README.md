# [00] - Hello World!

## Transaccional

Es un sistema transaccional -> Maneja transacciones con distintos Modulos "para cada Area".

MM y MD :: modulos logisticos :: Compras - Ventas.

```
/nse38 -> Transaccion de programas.
/nse37 -> Funciones.
```

#### Todo programa u objeto que deba crear en SAP comienza con 'z'

## Relacional

Es un sistema Realcional -> Basados en base de datos relaciones utilizan tablas con 'Primary Key" and 'Foreign Key'.

Si deseo todas las posiciones utilizo **foreing key**, una posicion particular **primary key**.

Orden de compras:

```
        1                                       N
EKKO (Cabezeras)                -->     EKPO (Posiciones)
Primary Key: Nro Orden. (1)          Primary Key: Nro Orden. Posicion. (2)
```

Por lo general hay 3 ambientes:
QA, Desarrolo y Produccion.

Un ambiente puede tener mas de un mandante. Por lo que todas las tablas tienen su *Primary Key* y su *Mandante*.

### SI CREO UNA TABLA TENGO QUE TENER MANDANTE COMO KEY

Los mandates son generados por el *basis*, quien se encarga de la infraestructura.

#### Creando una Tabla

```
    Armamos dos tablas (suponiendo Entidad Relacion):

        Auto    |--------<           Partes

    - Brand                        - Brand
    - Model                        - Model
    - Year                         - Year
                                   * Id Partes.
```

En SAP:

```

\\ z de custom - T de tabla - Modulo (CA) Cross Aplication _ CABECERA _ PARTES
Tabla de datos :: "ZTCA_CAB_PARTES"

Descripcion Breve :: "Cabecera de Auto Partes"


\\ A o C

Clase de Entrega :: A

/*
* Tipo A - Workbench - sno pide orden de Transporte al actualizar - Se replica en todos los mandantes.
* TIPO C - Customizing - Independiente del mandante.
*/

Campos      |  Clave | Val | Elemento de Datos   |    Tipo de dato  | Long | ... |Descricpion Breve | Grupo |
- MANDT     |  [X]   | [X] |        MANDT        |        CLNT      |   3  | ... |                  |       |
- MARCA     |  [X]   | [X] |        ZEDCA_MARCA  |        INT1      |   3  | ... |                  |       |
- EJERCICIO |  [X]   | [X] |        GJAHR        |        NUMC      |  ... | ... |       ...        |       |
----------------------------------------------------------------------------------------------------------------

Activando...

-> Actualizar Operaciones Tecnicas

Clase de Datos :: APPL0  \\ SIEMPRE APPL0
Categ. Tamano :: 0  \\ OJO Preguntar.

-> Definir categoria de ampliacion.
```

```
Creando Tipo de Dato:

Dominio :: Son los Valores posibles - Evita crear tablas para pocos valores.

Tipo Instalado :: INT, CHAR, ETC
```

```
SM30 permite vista de actualizacion.
```

### Creando Programa

```ABAP

Programa :: ZRCA_MODELOS

 > En ABAP

*Comentario*
 REPORT ZRCA_MODELOS "Comentario"

PARAMETERS p_marca  TYPE ztca_cab_partes marca
PARAMETERS p_marcaB TYPE zedca_marca  OBLIGATORY. "La mejor"

START-OF-SELECTION.

TYPES:
    BEGIN OF ts_autos,
    color TYPE ztca_cab_partes color,
    modelo TYPE ztca_cab_partes modelo.
    END OF ts_autos.

    tt_autos TYPE TABLE OF ts_autos

DATA:
    lt_autos TYPE TABLE OF tt_autos,
    lv_mnsg TYPE string.

refresh lt_autos.

select * FROM ztca_cab_partes
    INTO TABLE lt_autos
    WHERE marca = p_marca.

IF sy-subrc EQ 0.

ELSE.
    CONCATENATE 'No se encontraron registros para la marca seleccionada' p_marca INTO lv_mnsg.
    MESSAGE lv_mnsg TYPE 'E'DISPLAY LIKE 'E'

ENDIF.
```

ABBAT avanzo y ahora podemos reemplazar **TYPES** y **DATA** con:

```ABAP
select modelo  color FROM ztca_cab_partes
    INTO TABLE @DATA(lt_autos)
    WHERE marca = p_marca.
```

Siguiendo con el ejemplo:

```ABAP
DATA:
    ls_autos LIKE LINE OF lt_autos

SELECT modelo, color FROM ztca_cab_partes
    INTO TABLE @DATA(lt_autos)
    WHERE marca = p_marca.

IF sy-subrc EQ 0.

    LOOP AT lt_autos INTO ls_autos.
    WRITE:/ ls_autos modelos, ls_autos color.
    END LOOP.

ELSE.
    CONCATENATE 'No se encontraron registros para la marca seleccionada' p_marca INTO lv_mnsg.
    MESSAGE lv_mnsg TYPE 'E'DISPLAY LIKE 'E'

ENDIF.
```

Mas feliz, definiendo datas en ejecucion:

```ABAP
SELECT modelo, color FROM ztca_cab_partes
    INTO TABLE @DATA(lt_autos)
    WHERE marca = @p_marca.

IF sy-subrc EQ 0.

    LOOP AT lt_autos INTO DATA(ls_autos).
    WRITE:/ ls_autos modelos, ls_autos color.
    END LOOP.
ELSE.
ENDIF.
```