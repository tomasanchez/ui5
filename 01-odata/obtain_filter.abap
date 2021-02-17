* IMPORTING
*      !I_FILTERS type /IWBEP/T_MGW_SELECT_OPTION
*      !I_PROPERTY type ANY
*
* RETURNING
*  VALUE(E_VALUE) type bapilawrge.

METHOD OBTAIN_FILTER.

DATA: ls_filter TYPE /iwbep/s_mgw_select_option,
      ls_so     TYPE /iwbep/s_cod_select_option.

  " Obtener filtro
  READ TABLE i_filters WITH TABLE KEY property = i_property INTO ls_filter.
  CLEAR: e_value.
  IF sy-subrc EQ 0.
    LOOP AT ls_filter-select_options INTO ls_so.
      MOVE-CORRESPONDING ls_so TO e_value.
    ENDLOOP.
  ENDIF.

ENDMETHOD.
