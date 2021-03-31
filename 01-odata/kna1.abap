METHOD balancesset_get_entityset.

**********************************************************************
* C L I E N T E S
**********************************************************************

  TYPES: BEGIN OF ts_cliente,
    kunnr           TYPE kna1-kunnr, " Nro de Cliente
    name1           TYPE kna1-name1, " Nombre de Cliente
    ort01           TYPE kna1-ort01, " Poblacion/Localidad
    bzirk           TYPE knvv-bzirk, " Zona de Ventas Asignada (Numero)
*    saldo_cliente   TYPE zpceest015-saldo_cliente, " Total Cuenta Corriente
    END OF ts_cliente,
    tt_clientes TYPE TABLE OF ts_cliente.

  DATA: ls_cliente  TYPE ts_cliente,  " Estructura para mover los datos
        lt_kunnr    TYPE tt_clientes, " Para los clientes "seleccionados" desde vista
        lt_clientes TYPE tt_clientes. " Para el SQL

  " Filtros de estructura para los Kunnrs
  DATA:
            ls_filter           LIKE LINE OF it_filter_select_options,
            ls_select_options   LIKE LINE OF ls_filter-select_options.
  " Para tratar el entityset.
  DATA ls_entity LIKE LINE OF et_entityset.

**********************************************************************
* Obtencion de Clientes
**********************************************************************

*  Obtengo los filtros de Usuario (Name1), enrealidad el nombre, el Kunnr no interesa
  READ TABLE it_filter_select_options INTO ls_filter WITH KEY property = 'Kunnr'.

  IF sy-subrc EQ 0.
    LOOP AT ls_filter-select_options INTO ls_select_options.
      ls_cliente-kunnr = ls_select_options-low.
      APPEND ls_cliente TO lt_kunnr.
    ENDLOOP.

    IF lt_kunnr[] IS NOT INITIAL.
* Traigo la zona y el nombre desde el maestro de clientes y los datos comerciales porque el Modulo de funciones no lo hace
      SELECT kna1~kunnr kna1~name1 kna1~ort01 knvv~bzirk " Nro, Nombre, Poblacion y Zona de Ventas de Cliente
        FROM kna1
        INNER JOIN knvv ON kna1~kunnr EQ knvv~kunnr
        INTO TABLE lt_clientes
        FOR ALL ENTRIES IN lt_kunnr
        WHERE kna1~kunnr EQ lt_kunnr-kunnr.

**********************************************************************
* Tratamiento de Datos
**********************************************************************
      IF sy-subrc EQ 0.
*        Lo exporto al entityset
        CLEAR: ls_cliente.
        LOOP AT lt_clientes INTO ls_cliente.
          MOVE-CORRESPONDING ls_cliente TO ls_entity.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              input  = ls_cliente-bzirk
            IMPORTING
              output = ls_entity-bzirk.

          APPEND ls_entity TO et_entityset.
        ENDLOOP.

**********************************************************************
* Misc. entityset
**********************************************************************
        IF et_entityset[] IS NOT INITIAL.
* Aplico filtros de smart-table
          CALL METHOD /iwbep/cl_mgw_data_util=>filtering
            EXPORTING
              it_select_options = it_filter_select_options
            CHANGING
              ct_data           = et_entityset.

* Aplico ordenamientos de smart-table
          CALL METHOD /iwbep/cl_mgw_data_util=>orderby
            EXPORTING
              it_order = it_order
            CHANGING
              ct_data  = et_entityset.
        ENDIF.

* Aplico Paginacion, para el "Cargar Mas" de sap.m.Table
        IF is_paging IS NOT INITIAL.
          CALL METHOD /iwbep/cl_mgw_data_util=>paging
            EXPORTING
              is_paging = is_paging
            CHANGING
              ct_data   = et_entityset.
        ENDIF.

      ENDIF.
    ENDIF.
  ENDIF.

ENDMETHOD.
