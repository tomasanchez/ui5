
"Get Entity Set - Cabecera"
METHOD vueloset_get_entityset.

    DATA ls_entity LIKE LINE OF et_entityset.

    SELECT * FROM ztsd_datosvuelo
      INTO TABLE @DATA(lt_vuelos).
    IF sy-subrc EQ 0.
      LOOP AT lt_vuelos INTO DATA(ls_vuelos).
        MOVE-CORRESPONDING ls_vuelos TO ls_entity.
        APPEND ls_entity TO et_entityset.
      ENDLOOP.
    ENDIF.

ENDMETHOD.


"Get Entity"
METHOD vueloset_get_entity.

    DATA: ls_key_tab LIKE LINE OF it_key_tab,
          lv_vuelo   TYPE ztsd_svuelo-id_dep.

    READ TABLE it_key_tab INTO ls_key_tab WITH KEY name = 'Idvuelo'.
    IF sy-subrc EQ 0.
      lv_vuelo = ls_key_tab-value.

      SELECT SINGLE * FROM ztsd_datosvuelo
       INTO @DATA(ls_vuelo)
       WHERE idvuelo EQ @lv_vuelo.
      IF sy-subrc EQ 0.
        MOVE-CORRESPONDING ls_vuelo to er_entity.
      ENDIF.
    ENDIF.

ENDMETHOD.

"Create Entity"
METHOD vueloset_create_entity.

    *    Obtengo los datos a crear
        io_data_provider->read_entry_data( IMPORTING es_data =  er_entity ).
    
        " LOGICA PARA OBTENER EL ID a GENERAR
    
    *    MODIFY ztsd_datosvuelo FROM er_entity.
        COMMIT WORK.
    
        "Update
        UPDATE ztsd_flujovuelo SET estado = er_entity-estado WHERE idvuelo = er_entity-idvuelo.
        COMMIT WORK.
    
        "Delete
    *    DELETE ztsd_flujovuelo WHERE idvuelo = er_entity-idvuelo.
        COMMIT WORK.
    
      ENDMETHOD.


"Flujos de Vuelos - Posiciones"

"Set de Posiciones"
METHOD flujovueloset_get_entityset.

        DATA: ls_key_tab LIKE LINE OF it_key_tab,
              ls_entity  LIKE LINE OF et_entityset.
    
        READ TABLE it_key_tab INTO ls_key_tab WITH KEY name = 'Idvuelo'.
        IF sy-subrc EQ 0.
          SELECT * FROM ztsd_flujovuelo
            INTO TABLE @DATA(lt_flujos2)
            WHERE idvuelo = @ls_key_tab-value.
          LOOP AT lt_flujos2 INTO DATA(ls_flujos2).
            MOVE-CORRESPONDING ls_flujos2 TO ls_entity.
            APPEND ls_entity TO et_entityset.
          ENDLOOP.
    
        ELSE.
    
          SELECT * FROM ztsd_flujovuelo
              INTO TABLE @DATA(lt_flujos).
          LOOP AT lt_flujos INTO DATA(ls_flujos).
            MOVE-CORRESPONDING ls_flujos TO ls_entity.
            APPEND ls_entity TO et_entityset.
          ENDLOOP.
        ENDIF.
    
ENDMETHOD.


"Crear Posicion - Enity"
METHOD flujovueloset_get_entity.

    DATA: ls_key_tab LIKE LINE OF it_key_tab,
          lv_vuelo   TYPE ztsd_datosvuelo-idvuelo,
          lv_estado  TYPE ztsd_flujovuelo-estado.

    READ TABLE it_key_tab INTO ls_key_tab WITH KEY name = 'Idvuelo'.
    IF sy-subrc EQ 0.
      lv_vuelo = ls_key_tab-value.

      READ TABLE it_key_tab INTO ls_key_tab WITH KEY name = 'Estado'.
      IF sy-subrc EQ 0.
        lv_estado = ls_key_tab-value.

        SELECT SINGLE * FROM ZTSD_FLUJOVUELO
         INTO @DATA(ls_flujo)
         WHERE idvuelo EQ @lv_vuelo
           AND estado  EQ @lv_estado.
        IF sy-subrc EQ 0.
          MOVE-CORRESPONDING ls_flujo TO er_entity.
        ENDIF.

      ENDIF.

    ENDIF.

  ENDMETHOD.

