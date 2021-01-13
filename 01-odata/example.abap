METHOD reporteset_get_entityset.

    TYPES: BEGIN OF ts_report,
                matnr           TYPE mara-matnr,
                kostl           TYPE csks-kostl,
                menge           TYPE mseg-menge,
                dmbtr           TYPE mseg-dmbtr,
                maktx           TYPE makt-maktx,
           END OF
                ts_report,
                tt_report       TYPE TABLE OF ts_report.
  
    DATA    ls_entity           LIKE LINE OF et_entityset.
  
    DATA:   lt_report           TYPE tt_report,
            ls_report           TYPE ts_report.
  
    DATA:   lv_budat_start      TYPE mseg-budat_mkpf,
            lv_budat_end        TYPE mseg-budat_mkpf,
            lr_budat            TYPE RANGE OF mseg-budat_mkpf,
            lrs_budat           LIKE LINE OF lr_budat,
            lv_matnr            TYPE mara-matnr,
            lr_matnr            TYPE RANGE OF mara-matnr,
            lrs_matnr           LIKE LINE OF lr_matnr,
            lv_kostl            TYPE csks-kostl,
            lr_kostl            TYPE RANGE OF csks-kostl,
            lrs_kostl           LIKE LINE OF lr_kostl,
            ls_filter           LIKE LINE OF it_filter_select_options,
            ls_select_options   LIKE LINE OF ls_filter-select_options.
  
    FIELD-SYMBOLS:
           <fs_entityset> LIKE LINE OF et_entityset.
  
*  Obtengo el filtro de Fechas
    CALL METHOD me->obtener_filtro_fecha
      EXPORTING
        i_filters      = it_filter_select_options
      IMPORTING
        e_value_inicio = lv_budat_start
        e_value_fin    = lv_budat_end.
    IF lv_budat_start IS NOT INITIAL.
  
      CLEAR lrs_budat.
      lrs_budat-sign = 'I'.
      lrs_budat-option = 'BT'.
      lrs_budat-low = lv_budat_start.
      lrs_budat-high = lv_budat_end.
      APPEND lrs_budat TO lr_budat.
    ELSE.
      CLEAR lrs_budat.
      lrs_budat-sign = 'I'.
      lrs_budat-option = 'BT'.
      lrs_budat-low = '19000101'.
      lrs_budat-high = '99991231'.
      APPEND lrs_budat TO lr_budat.
    ENDIF.
 
*  Obtengo el filtro de Matnrs
    READ TABLE it_filter_select_options INTO ls_filter WITH KEY property = 'Matnr'.
    IF sy-subrc EQ 0.
      LOOP AT ls_filter-select_options INTO ls_select_options.
        CLEAR lrs_matnr.
        lrs_matnr-sign = 'I'.
        lrs_matnr-option = 'EQ'.
        lrs_matnr-low = ls_select_options-low.
        APPEND lrs_matnr TO lr_matnr.
      ENDLOOP.
    ENDIF.
  
*  Obtengo el filtro de Kostls
    READ TABLE it_filter_select_options INTO ls_filter WITH KEY property = 'Kostl'.
    IF sy-subrc EQ 0.
      LOOP AT ls_filter-select_options INTO ls_select_options.
        CLEAR lrs_kostl.
        lrs_kostl-sign = 'I'.
        lrs_kostl-option = 'EQ'.
        lrs_kostl-low = ls_select_options-low.
        APPEND lrs_kostl TO lr_kostl.
      ENDLOOP.
    ENDIF.
  
    REFRESH lt_report.
  
    SELECT mseg~matnr mseg~kostl mseg~menge mseg~dmbtr makt~maktx
      FROM mseg
      INNER JOIN makt ON makt~matnr EQ mseg~matnr
      INTO TABLE lt_report
      WHERE mseg~budat_mkpf IN lr_budat
      AND mseg~matnr IN lr_matnr
      AND makt~spras EQ 'S'
      AND mseg~kostl IN lr_kostl.
  
    SORT lt_report STABLE BY matnr DESCENDING
                             kostl ASCENDING
                             menge DESCENDING.
  
    IF lt_report[] IS NOT INITIAL.
      CLEAR: ls_report.
      LOOP AT lt_report INTO ls_report.
  
        MOVE-CORRESPONDING ls_report TO ls_entity.
  
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = ls_report-kostl
          IMPORTING
            output = ls_entity-kostl.
  
        " Busco si ya esta
        READ TABLE et_entityset ASSIGNING <fs_entityset> WITH KEY matnr = ls_report-matnr.
        IF sy-subrc EQ 0.
          IF <fs_entityset>-kostl EQ ls_entity-kostl.
            " Acumulo valorers y cantidades
            <fs_entityset>-menge = <fs_entityset>-menge + ls_report-menge.
            <fs_entityset>-dmbtr = <fs_entityset>-dmbtr + ls_report-dmbtr.
          ELSE.
            APPEND ls_entity TO et_entityset.
          ENDIF.
          " Si no esta lo meto al et_entityset
        ELSE.
          APPEND ls_entity TO et_entityset.
        ENDIF.
  
      ENDLOOP.
    ENDIF.
  
  
  ENDMETHOD.
