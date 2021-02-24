METHOD remitosset_get_entityset.

  DATA:
*       et_entityset related
        lt_remitos      TYPE TABLE OF zpceest002,
        ls_remito       LIKE LINE OF lt_remitos,
        ls_entity       LIKE LINE OF et_entityset,
*       Variables de filtrado
        lv_kunag        TYPE zpceest002-kunag, " Usuario
        wa_kunag        TYPE bapilawrge,
        lv_dat_begin    TYPE zpceest002-fecha, " Fecha
        lv_dat_end      TYPE zpceest002-fecha,
        wa_wadat        TYPE bapilawrge,
        lv_werks        TYPE zpceest002-werks, " Centro
        wa_werks        TYPE bapilawrge,
*        Count de Tile (Toneladas)
        lv_tns          TYPE zpceest002-lfimg.

  CLEAR: lv_kunag, lv_dat_begin, lv_dat_end, lv_werks.

*  Obtengo el filtro de Usuario
  CLEAR wa_kunag.
  CALL METHOD me->obtener_valor_filtro
    EXPORTING
      i_filters  = it_filter_select_options
      i_property = 'Kunag'
      i_opcional = 'X'
    RECEIVING
      e_value    = lv_kunag.
  IF lv_kunag IS NOT INITIAL.
    " Asigno al bapilawrge
    CLEAR: wa_kunag.
    wa_wadat-sign = 'I'.
    wa_kunag-option = 'EQ'.
    wa_kunag-low = lv_kunag.
  ELSE.
    wa_wadat-sign = 'I'.
    wa_kunag-option = 'EQ'.
    wa_kunag-low = '100027'. " Sy-uname
  ENDIF.

* Obtengo el filtro de Fecha
  CLEAR wa_wadat.
  CALL METHOD me->obtener_filtro_fecha
    EXPORTING
      i_filters      = it_filter_select_options
    IMPORTING
      e_value_inicio = lv_dat_begin
      e_value_fin    = lv_dat_end.
  IF lv_dat_begin IS NOT INITIAL.
    wa_wadat-sign = 'I'.
    wa_wadat-option = 'BT'.
    wa_wadat-low = lv_dat_begin.
    wa_wadat-high = lv_dat_end.
  ELSE. " Si no hay fecha traigo por default ultima semana
    wa_wadat-sign = 'I'.
    wa_wadat-option = 'BT'.
    wa_wadat-low = '20130505'. " sydatum - 7
    wa_wadat-high = sy-datum.
  ENDIF.


*  Obtengo el filtro de Centros
  CLEAR wa_werks.
  CALL METHOD me->obtener_valor_filtro
    EXPORTING
      i_filters  = it_filter_select_options
      i_property = 'Werks'
      i_opcional = 'X'
    RECEIVING
      e_value    = lv_werks.
  IF lv_werks IS NOT INITIAL.
    " Asigno al bapilawrge
    wa_werks-sign = 'I'.
    wa_werks-option = 'EQ'.
    wa_werks-low = lv_werks.
  ENDIF.

* Obtengo los remitos
  CALL FUNCTION 'ZPCE_OBTENER_REMITOS'
 EXPORTING
*   I_MATNR           =
*   i_werks            = wa_werks
   i_wadat_ist        = wa_wadat
*   I_BZIRK           =
   i_kunag            = wa_kunag
* IMPORTING
*   E_RETURN          =
   TABLES
     t_remitos        = lt_remitos.

  CLEAR lv_tns.

* Muevo a entity-set
  LOOP AT lt_remitos INTO ls_remito.
*    Acumulo toneladas
    lv_tns = lv_tns + ls_remito-lfimg.

    MOVE-CORRESPONDING ls_remito TO ls_entity.
    APPEND ls_entity TO et_entityset.
  ENDLOOP.

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

* Devulvo la cantidad de toneladas para el Tile
  es_response_context-count = lv_tns.
  
* Aplico Paginacion
    IF is_paging IS NOT INITIAL.
      CALL METHOD /iwbep/cl_mgw_data_util=>paging
        EXPORTING
          is_paging = is_paging
        CHANGING
          ct_data   = et_entityset.
    ENDIF.

  FIELD-SYMBOLS:
                 <fs_entity> LIKE LINE OF et_entityset.

  LOOP AT et_entityset ASSIGNING <fs_entity>.
*    Elimino ceros
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = <fs_entity>-kunag " Solicitante
      IMPORTING
        output = <fs_entity>-kunag.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = <fs_entity>-matnr " Material
      IMPORTING
        output = <fs_entity>-matnr.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = <fs_entity>-bzirk " Zona de Ventas
      IMPORTING
        output = <fs_entity>-bzirk.

    <fs_entity>-Certificado = <fs_entity>-Entrega. " Prueba de Certificado de Calidad

  ENDLOOP.

ENDMETHOD.
