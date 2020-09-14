*----------------------------------------------------------*
* EXAMPLE
*----------------------------------------------------------*

REPORT ZRCA_MODELOS

PARAMETERS p_marca TYPE zedca_marca  OBLIGATORY.

START-OF-SELECTION.

TYPES:
    BEGIN OF ts_report
    descripcion     TYPE ztca_cab_marcas descripcion,
    color           TYPE ztca_cab_partes color,
    modelo          TYPE ztca_cab_partes modelo.
    END OF ts_report.

DATA:
    lt_report TYPE TABLE OF ts_report.
    ls_report LIKE LINE OF lt_report.

*INNER JOIN*
* SELECT ztca_cab_partes modelo, ztca_cab_partes color, ztca_cab_marcas descripcion FROM ztca_cab_partes.
*   INNER JOIN ztca_marcas ON ztca_cab_partes marca EQ ztca_marcas marca
*    INTO TABLE lt_report
*       WHERE ztca_cab_partes color = 'NEGRO'
*        AND ztca_marcas descripcion = 'FORD'.

*IF sy-subrc EQ 0.
*    LOOP AT lt_report INTO DATA(ls_report).
*        WRITE:/ ls_report~descripcion, ls_report~modelo, ls_report~color.
*    ENDLOOP.

* FOR ALL ENTRIES

SELECT modelo, marca, color FROM ztca_cab_partes
INTO TABLE @DATA(lt_ztca_marcas)
FOR ALL ENTRIES IN @lt_ztca_cab_partes
WHERE marca EQ @lt_ztca_cab_partes~marca.

IF sy-subrc EQ 0.

    LOOP AT lt_ztca_cab_partes INTO DATA(ls_ztca_partes).
    
        READ TABLE  lt_ztca_marcas INTO DATA(ls_ztca_marcas) WITH KEY marca = ls_ztca_cab_partes~marca
        IF sy-subrc EQ 0.
            WRITE:/ ls_ztca_marcas~descripcion, ls_ztca_partes~modelo, ls_ztca_partes~marca.
        ENDIF.
    ENDLOOP.
    
ENDIF.