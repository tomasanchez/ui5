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

  DATA: ls_cliente  TYPE ts_cliente,                    " Estructura para mover los datos
        lt_clientes TYPE tt_clientes,                   " Para el SQL
**********************************************************************
* Kunnrs
**********************************************************************
        lt_kunnr    TYPE STANDARD TABLE OF kund01,      " Para los clientes "seleccionados" desde vista
        ls_kunnr    LIKE LINE OF lt_kunnr,              " Estructura para mover clientes "seleccionados"
**********************************************************************
* Saldos
**********************************************************************
        lt_saldos TYPE STANDARD TABLE OF zpceest015,    " Tabla de Saldos
        ls_saldo  LIKE LINE OF lt_saldos,               " Estructura para mover Saldos
**********************************************************************
* Resumen Individual
**********************************************************************
        lt_resumen  TYPE STANDARD TABLE OF zpceest026,  " Tabla de resumenes individuales
        ls_resumen  LIKE LINE OF lt_resumen,            " Estructura para mover Resumenes
**********************************************************************
* Credito Operativo
**********************************************************************
        lt_credito  TYPE STANDARD TABLE OF zpceest022,  " Tabla de credito operativo
        ls_credito  LIKE LINE OF lt_credito,            " Estructura para mover creditos
        lt_calculo  TYPE STANDARD TABLE OF zpceest027,  " Tabla de Calculos de Lineas de credito
        ls_calculo  LIKE LINE OF lt_calculo,            " Estructura para mover calculos de linea de credito
**********************************************************************
* Cereales
**********************************************************************
        lt_cereales TYPE STANDARD TABLE OF zekcuerdos,  " Table de Seriales
        ls_cereal   LIKE LINE OF lt_cereales,           " Estructura para mover cereales
**********************************************************************
* Comprometido No Documentado (CND)
**********************************************************************
        lt_cnd      TYPE TABLE OF zpceest023,           " Tabla de datos CND
        ls_cnd      LIKE LINE OF lt_cnd.                " Estructura para mover CND


  " Filtros de estructura para los Kunnrs
  DATA:
            ls_filter           LIKE LINE OF it_filter_select_options,
            ls_select_options   LIKE LINE OF ls_filter-select_options.
  " Para tratar el entityset.
  DATA ls_entity LIKE LINE OF et_entityset.

  " Para return de los modulos de funciones
  DATA ls_return TYPE bapiret2.

**********************************************************************
* Obtencion de Clientes
**********************************************************************

*  Obtengo los filtros de Usuario (Name1), enrealidad el nombre, el Kunnr no interesa
  READ TABLE it_filter_select_options INTO ls_filter WITH KEY property = 'Kunnr'.

  IF sy-subrc EQ 0.
    LOOP AT ls_filter-select_options INTO ls_select_options.
      ls_kunnr-kunnr = ls_select_options-low.
      APPEND ls_kunnr TO lt_kunnr.
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

        REFRESH: lt_resumen, lt_cnd, lt_saldos, lt_credito.

        " Traigo los resumenes individuales.
        CALL FUNCTION 'ZPCE_CC_RESUMEN_INDIVIDUAL'
          TABLES
            t_clientes = lt_kunnr     " Los kunnrs
            t_resumen  = lt_resumen.  " Detalle de Resumen

        " Traigo los CNDS
*        CALL FUNCTION 'ZPCE_COMPROMETIDO_NO_DOC'
*          IMPORTING
*            e_return      = ls_return
*          TABLES
*            t_comp_no_doc = lt_cnd   " Comprometido No Documentado
*            t_clientes    = lt_kunnr. " Los kunnrs.

        CALL FUNCTION 'ZPCE_CUENTA_CORRIENTE'
          TABLES
            t_linea_credito_operativa = lt_credito
            t_cta_saldos              = lt_saldos
*           T_CTA_DET_SAL             =
*           T_CTA_DET_OPE             =
*           T_CTA_DET_FIN             =
*           T_VALOR_COMERCIAL         =
*           T_VALOR_COMERCIAL_DET     =
*           T_COMP_NO_DOC             =
*           T_COMP_NO_DOC_DET         =
            t_calculos                = lt_calculo
            t_clientes                = lt_kunnr
*           T_CTA_DET_RD              =
            t_cto_pend                = lt_cereales
*           T_CTA_DET_RD_RIO          =
          .

*        Lo exporto al entityset
        CLEAR: ls_cliente.
        LOOP AT lt_clientes INTO ls_cliente.
          MOVE-CORRESPONDING ls_cliente TO ls_entity.

          "  Tomo los datos de la funcion de resumen individual
          READ TABLE lt_resumen INTO ls_resumen WITH KEY kunnr = ls_cliente-kunnr.
          IF sy-subrc EQ 0.
            ls_entity-cnd_vencido      = ls_resumen-cnd_vencido.     " CND Vencido
            ls_entity-cnd_a_venc       = ls_resumen-cnd_avencer.     " CND a Vencer
            ls_entity-cnd_total        = ls_resumen-cnd_vencido + ls_resumen-cnd_avencer. " CND Total
            ls_entity-valor_comercial  = ls_resumen-valor_comercial. " Valor Comercial
            ls_entity-linea_disp       = ls_resumen-credito.         " Linea de Credito Disponible
          ENDIF.

          " Obtengo la liena de credito, calculo + operativo
          READ TABLE lt_credito INTO ls_credito WITH KEY kunnr = ls_cliente-kunnr.
          IF sy-subrc EQ 0.
            ls_entity-linea_acordada = ls_credito-klimk.            " Linea Acordada
          ENDIF.
          READ  TABLE lt_calculo INTO ls_calculo WITH KEY kunnr = ls_cliente-kunnr.
          IF sy-subrc EQ 0.
            ls_entity-linea_disp      = ls_calculo-lin_cred_disp.   " Linea de credito Disponible
            ls_entity-linea_afectada  = ls_calculo-lin_cred_afec.   " Linea de credito Afectada
            ls_entity-pos_proy        = ls_calculo-pos_fin_proy.    " Posicion Proyectada
          ENDIF.

          " Obtengo los cereales (Granos)
          LOOP AT lt_cereales INTO ls_cereal WHERE name1 = ls_cliente-name1.
            " Entregados
            ls_entity-g_e_nf = ls_entity-g_e_nf + ls_cereal-usd_entr_pend_fijar.                          " Grano Entregado no Fijado
            ls_entity-g_e_total = ls_entity-g_e_total + ls_entity-g_e_nf + ls_cereal-usd_entr_pend_liqui. " Grano Entregado Total
            " No Entregados
            ls_entity-g_ne_liq =  ls_entity-g_ne_liq +  ls_cereal-usd_liq_no_entregadas.                    " Grano NO entregado Liquidado
            ls_entity-g_ne_avencer = ls_entity-g_ne_avencer + ls_cereal-usd_entr_pend_liqui.                " Grano NO entregado A vencer
            ls_entity-g_ne_vencido = ls_entity-g_ne_vencido + ls_cereal-usd_pend.                           " Grano NO entregado Vencido
            ls_entity-g_e_total = ls_entity-g_e_total + ls_entity-g_ne_liq +
             ls_entity-g_ne_avencer - ls_entity-g_ne_vencido.                                               " Grano No Entregado Total
          ENDLOOP.

          "  Tomo los datos de la funcion de CNDS
*          READ TABLE lt_cnd INTO ls_cnd WITH KEY kunnr = ls_cliente-kunnr.
*          IF sy-subrc EQ 0.
*            ls_entity-cnd_total       = ls_cnd-acucom.  " CND Total
*            ls_entity-cnd_a_venc      = ls_cnd-avencer. " CND a Vencer
*            ls_entity-cnd_vencido     = ls_cnd-vencido. " CND Vencido
*          ELSE.
*            ls_entity-cnd_total     = 0.
*            ls_entity-cnd_a_venc    = 0.
*            ls_entity-cnd_vencido   = 0.
*          ENDIF.

          "  Tomo los datos de la funcion de Saldos
          READ TABLE lt_saldos INTO ls_saldo WITH KEY kunnr = ls_cliente-kunnr.
          IF sy-subrc EQ 0.
*           CC
            ls_entity-saldo_cliente   = ls_saldo-saldo_final.                                 " CC Total
            ls_entity-saldo_a_venc    = ls_saldo-saldo_final - ls_saldo-f_saldo_vencido.      " CC A Vencer
            ls_entity-saldo_vencido   = ls_saldo-f_saldo_vencido.                             " CC Vencido
*           CPD
            ls_entity-cpd_galicia     = ls_saldo-g_saldo_rd.                                              " CPD Galicia
            ls_entity-cpd_rio         = ls_saldo-g_saldo_rd_rio.                                          " CPD Rio
            ls_entity-cpd_echeq       = 0.                                                                " CPD E-Cheque
            ls_entity-cpd_total       = ls_entity-cpd_galicia + ls_entity-cpd_rio + ls_entity-cpd_echeq.  " CPD TOTAL
          ENDIF.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              input  = ls_cliente-bzirk
            IMPORTING
              output = ls_entity-bzirk.

          APPEND ls_entity TO et_entityset.

          CLEAR: ls_entity, ls_cnd, ls_resumen.
        ENDLOOP.

**********************************************************************
* Misc. entityset
**********************************************************************
        IF et_entityset[] IS NOT INITIAL.
* Aplico filtros de smart-table
*          CALL METHOD /iwbep/cl_mgw_data_util=>filtering
*            EXPORTING
*              it_select_options = it_filter_select_options
*            CHANGING
*              ct_data           = et_entityset.

* Aplico ordenamientos de smart-table
          IF it_order[] IS NOT INITIAL.
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
  ENDIF.

ENDMETHOD.
