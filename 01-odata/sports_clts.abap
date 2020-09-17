
" :: Clientes - Cabecera ::""

"Creae entity"

method CLIENTESSET_CREATE_ENTITY.
    
    DATA ls_entity TYPE ztca_gym_clts.

    DATA lo_message_container TYPE REF TO /iwbep/if_message_container.
    FIELD-SYMBOLS: <fs_key_tab> TYPE /iwbep/s_mgw_name_value_pair.
    
    lo_message_container = /iwbep/if_mgw_conv_srv_runtime~get_message_container(  ).

    io_data_provider->read_entry_data( IMPORTING es_data = er_entity ).

    ls_entity-nombre    = er_entity-nombre.
    ls_entity-apellido  = er_entity-apellido.
    ls_entity-post      = er_entity-post.
    ls_entity-telf      = er_entity-telf.
    ls_entity-calle     = er_entity-calle.

    INSERT ztca_gym_clts 
        FROM ls_entity.
    IF sy-subrc EQ 0.

        CALL METHOD lo_message_container->add_message
            EXPORTING 
            iv_msg_type                 = 'S'
            iv_msg_id                   = 'SABAPDOCU'
            iv_msg_number               = '888'
            iv_msg_text                 = 'Cliente creado exitosamente'
            iv_add_to_response_header   = abap_true.

    ELSE .
        CALL METHOD lo_message_container->add_message
        EXPORTING 
        iv_msg_type                 = 'E'
        iv_msg_id                   = 'SABAPDOCU'
        iv_msg_number               = '888'
        iv_msg_text                 = 'Cliente no se ha podido crear'.

        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
        message_container = lo_message_container.
        
    ENDIF.

    COMMIT WORK.

endmethod.


"Delete entity"
METHOD CLIENTESSET_DELETE_ENTITY.

    DATA: lv_id_clte TYPE ztca_gym_clts-id_clte.
    DATA lo_message_container TYPE REF TO /iwbep/if_message_container.
    FIELD-SYMBOLS: <fs_key_tab> TYPE /iwbep/s_mgw_name_value_pair.

    READ TABLE it_key_tab ASSIGNING <fs_key_tab>
        WITH KEY name = 'IdClte'.

        IF sy-subrc EQ 0.
            lv_id_clte = <fs_key_tab>-value.
        ENDIF.
    
    DELETE FROM ztca_gym_clts WHERE id_clte EQ @lv_id_clte.

    IF sy-subrc EQ 0.

        CALL METHOD lo_message_container->add_message
            EXPORTING 
            iv_msg_type                 = 'S'
            iv_msg_id                   = 'SABAPDOCU'
            iv_msg_number               = '888'
            iv_msg_text                 = 'Cliente borrado exitosamente'
            iv_add_to_response_header   = abap_true.

    ELSE .
        CALL METHOD lo_message_container->add_message
        EXPORTING 
        iv_msg_type                 = 'E'
        iv_msg_id                   = 'SABAPDOCU'
        iv_msg_number               = '888'
        iv_msg_text                 = 'Cliente no se ha podido borrar'.

        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
        message_container = lo_message_container.
        
    ENDIF.

    COMMIT WORK.

endmethod.    


method CLIENTESSET_UPDATE_ENTITY.

    DATA: lv_id_clte TYPE ztca_gym_clts-id_clte.
    DATA lo_message_container TYPE REF TO /iwbep/if_message_container.
    FIELD-SYMBOLS: <fs_key_tab> TYPE /iwbep/s_mgw_name_value_pair.


    READ TABLE it_key_tab ASSIGNING <fs_key_tab>
    WITH KEY name = 'IdClte'.

    IF sy-subrc EQ 0.
        lv_id_clte = <fs_key_tab>-value.
    ENDIF.

    io_data_provider->read_entry_data( IMPORTING es_data = er_entity ).

    UPDATE ztca_gym_clts
    SET nombre      = er_entity-nombre
        apellido    = er_entity-apellido
        calle       = er_entity-calle
        telf        = er_entity-telf
        post        = er_entity-post
    WHERE id_clte EQ lv_id_clte.

    IF sy-subrc EQ 0.

        CALL METHOD lo_message_container->add_message
            EXPORTING 
            iv_msg_type                 = 'S'
            iv_msg_id                   = 'SABAPDOCU'
            iv_msg_number               = '888'
            iv_msg_text                 = 'Cliente actualizado exitosamente'
            iv_add_to_response_header   = abap_true.

    ELSE .
        CALL METHOD lo_message_container->add_message
        EXPORTING 
        iv_msg_type                 = 'E'
        iv_msg_id                   = 'SABAPDOCU'
        iv_msg_number               = '888'
        iv_msg_text                 = 'Cliente no se ha podido actualizar'.

        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
        message_container = lo_message_container.
        
    ENDIF.

    COMMIT WORK.


endmethod.


" Get Entity Set - Cabecera "

METHOD clientesset_get_entityset.

    DATA ls_entity LIKE LINE OF et_entityset.

    SELECT * FROM ztca_gym_clts
      INTO TABLE @DATA(lt_clientes).
    IF sy-subrc EQ 0.
      LOOP AT lt_clientes INTO DATA(ls_clientes).
        MOVE-CORRESPONDING ls_clientes TO ls_entity.
        APPEND ls_entity TO et_entityset.
      ENDLOOP.
    ENDIF.
    
ENDMETHOD.

"Get Entity - Clientes"

METHOD clientesset_get_entity.

    DATA: ls_key_tab LIKE LINE OF it_key_tab,
          lv_cliente   TYPE ztca_gym_clts-id_clte.

    READ TABLE it_key_tab INTO ls_key_tab WITH KEY name = 'id_clte'.
    IF sy-subrc EQ 0.
      lv_cliente = ls_key_tab-value.
    SELECT SINGLE * FROM ztca_gym_clts
       INTO @DATA(ls_cliente)
       WHERE id_clte EQ @lv_cliente.
      IF sy-subrc EQ 0.
        MOVE-CORRESPONDING ls_cliente to er_entity.
      ENDIF.
    ENDIF.

ENDMETHOD.




" :: Detalle - Campos - Deportes :: "

method DEPORTERSET_CREATE_ENTITY.
    
    DATA ls_entity TYPE ztca_gym_dep.

    DATA lo_message_container TYPE REF TO /iwbep/if_message_container.
    FIELD-SYMBOLS: <fs_key_tab> TYPE /iwbep/s_mgw_name_value_pair.
    
    lo_message_container = /iwbep/if_mgw_conv_srv_runtime~get_message_container(  ).

    io_data_provider->read_entry_data( IMPORTING es_data = er_entity ).

    ls_entity-costo      = er_entity-costo.
    ls_entity-horario    = er_entity-horario.
    ls_entity-profe      = er_entity-profe.

    INSERT ztca_gym_dep 
        FROM ls_entity.
    IF sy-subrc EQ 0.

        CALL METHOD lo_message_container->add_message
            EXPORTING 
            iv_msg_type                 = 'S'
            iv_msg_id                   = 'SABAPDOCU'
            iv_msg_number               = '888'
            iv_msg_text                 = 'Deporte creado exitosamente'
            iv_add_to_response_header   = abap_true.

    ELSE .
        CALL METHOD lo_message_container->add_message
        EXPORTING 
        iv_msg_type                 = 'E'
        iv_msg_id                   = 'SABAPDOCU'
        iv_msg_number               = '888'
        iv_msg_text                 = 'Deporte no se ha podido crear'.

        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
        message_container = lo_message_container.
        
    ENDIF.

    COMMIT WORK.
endmethod.

method DEPORTESSET_DELETE_ENTITY.

    DATA:   lv_id_clte TYPE ztca_gym_clts-id_clte,
            lv_id_dep TYPE ztca_gym_dep-id_dep.

    DATA lo_message_container TYPE REF TO /iwbep/if_message_container.
    FIELD-SYMBOLS: <fs_key_tab> TYPE /iwbep/s_mgw_name_value_pair.

    READ TABLE it_key_tab ASSIGNING <fs_key_tab>
    WITH KEY name = 'IdClte'.

    IF sy-subrc EQ 0.
        lv_id_clte = <fs_key_tab>-value.
    ENDIF.

    READ TABLE it_key_tab ASSIGNING <fs_key_tab>
    WITH KEY name = 'IdDep'.

    IF sy-subrc EQ 0.
        lv_id_dep = <fs_key_tab>-value.
    ENDIF.

    DELETE FROM ztca_gym_dep 
    WHERE id_clte EQ lv_id_clte
    AND id_dep EQ lv_id_dep.

    IF sy-subrc EQ 0.

        CALL METHOD lo_message_container->add_message
            EXPORTING 
            iv_msg_type                 = 'S'
            iv_msg_id                   = 'SABAPDOCU'
            iv_msg_number               = '888'
            iv_msg_text                 = 'Deporte borrado exitosamente'
            iv_add_to_response_header   = abap_true.

    ELSE .
        CALL METHOD lo_message_container->add_message
        EXPORTING 
        iv_msg_type                 = 'E'
        iv_msg_id                   = 'SABAPDOCU'
        iv_msg_number               = '888'
        iv_msg_text                 = 'Deporte no se ha podido borrar'.

        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
        message_container = lo_message_container.
        
    ENDIF.

    COMMIT WORK.
endmethod.

method DEPORTESSET_UPDATE_ENTITY.
    DATA:   lv_id_clte TYPE ztca_gym_clts-id_clte,
    lv_id_dep TYPE ztca_gym_dep-id_dep.

    DATA lo_message_container TYPE REF TO /iwbep/if_message_container.
    FIELD-SYMBOLS: <fs_key_tab> TYPE /iwbep/s_mgw_name_value_pair.

    READ TABLE it_key_tab ASSIGNING <fs_key_tab>
    WITH KEY name = 'IdClte'.

    IF sy-subrc EQ 0.
    lv_id_clte = <fs_key_tab>-value.
    ENDIF.

    READ TABLE it_key_tab ASSIGNING <fs_key_tab>
    WITH KEY name = 'IdDep'.

    IF sy-subrc EQ 0.
    lv_id_dep = <fs_key_tab>-value.
    ENDIF.
    
    UPDATE ztca_gym_dep
    SET horarios    = er_entity-horarios
        profe       = er_entity-profe
        costo       = er_entity-costo.
    WHERE id_clte   EQ lv_id_clte
    AND   id_dep    EQ lv_id_dep.

    IF sy-subrc EQ 0.

        CALL METHOD lo_message_container->add_message
            EXPORTING 
            iv_msg_type                 = 'S'
            iv_msg_id                   = 'SABAPDOCU'
            iv_msg_number               = '888'
            iv_msg_text                 = 'Deporte actualizado exitosamente'
            iv_add_to_response_header   = abap_true.

    ELSE .
        CALL METHOD lo_message_container->add_message
        EXPORTING 
        iv_msg_type                 = 'E'
        iv_msg_id                   = 'SABAPDOCU'
        iv_msg_number               = '888'
        iv_msg_text                 = 'Deporte no se ha podido actualizar'.

        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
        message_container = lo_message_container.
        
    ENDIF.
    COMMIT WORK.
endmethod.

" Get Entity Set "

METHOD deportesset_get_entityset.

        DATA: ls_key_tab LIKE LINE OF it_key_tab,
              ls_entity  LIKE LINE OF et_entityset.
    
        READ TABLE it_key_tab INTO ls_key_tab WITH KEY name = 'IdClte'.
        IF sy-subrc EQ 0.
          SELECT * FROM ztca_gym_dep
            INTO TABLE @DATA(lt_deportes2)
            WHERE id_clte = @ls_key_tab-value.
          LOOP AT lt_deportes2 INTO DATA(ls_deportes2).
            MOVE-CORRESPONDING ls_deportes2 TO ls_entity.
            APPEND ls_entity TO et_entityset.
          ENDLOOP.
    
        ELSE.
    
          SELECT * FROM ztca_gym_dep
              INTO TABLE @DATA(lt_deportes).
          LOOP AT lt_deportes INTO DATA(ls_deportes).
            MOVE-CORRESPONDING ls_deportes TO ls_entity.
            APPEND ls_entity TO et_entityset.
          ENDLOOP.
        ENDIF.
    
ENDMETHOD.

" Get entity "

METHOD deportesset_get_entity.

    DATA: ls_key_tab    LIKE LINE OF it_key_tab,
          lv_cliente    TYPE ztca_gym_clts-id_clte,
          lv_deporte    TYPE ztca_gym_dep-id_dep.

    READ TABLE it_key_tab INTO ls_key_tab WITH KEY name = 'IdClte'.
    IF sy-subrc EQ 0.
      lv_cliente = ls_key_tab-value.

      READ TABLE it_key_tab INTO ls_key_tab WITH KEY name = 'IdDep'.
      IF sy-subrc EQ 0.
        lv_deporte = ls_key_tab-value.

        SELECT SINGLE * FROM ztca_gym_dep
         INTO @DATA(ls_deporte)
         WHERE id_clte EQ @lv_cliente
           AND id_dep  EQ @lv_deporte.
        IF sy-subrc EQ 0.
          MOVE-CORRESPONDING ls_deporte TO er_entity.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.