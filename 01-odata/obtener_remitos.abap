METHOD obtener_remitos_3.

* Obtengo la Fecha de Vencimiento del Acuerdo
  DATA lv_gueen TYPE vbak-gueen.
  CLEAR: e_gueen.
  SELECT SINGLE gueen
    FROM vbak
    INTO lv_gueen
    WHERE vbeln EQ i_remito-ac_negocio.
  MOVE lv_gueen TO e_gueen.

* Obtengo la Poblacion Dest Pe.
  CLEAR: e_adrnr.
  SELECT SINGLE adrc~city1
    FROM adrc
    INNER JOIN vbpa ON vbpa~adrnr EQ adrc~addrnumber
    INTO e_adrnr
    WHERE vbpa~vbeln EQ i_remito-pl_entrega.

* Obtengo las patentes
  DATA: ls_likp TYPE likp.
  SELECT SINGLE traid xabln " Del camion y/o del remolque
    FROM likp
    INTO ls_likp
    WHERE vbeln EQ i_remito-entrega.
  IF ls_likp-xabln IS NOT INITIAL. " Si hay remolque concateno
    CONCATENATE ls_likp-traid ls_likp-xabln INTO e_patente
    SEPARATED BY '-'.
  ELSE.
    e_patente = ls_likp-traid. " Sino devuelvo la patente normal.
  ENDIF.

* Por ultimo obtengo el DNI Po.
  CLEAR: e_remark.
  SELECT SINGLE adrct~remark
    FROM adrct
    INNER JOIN vbpa ON vbpa~adrnr EQ adrct~addrnumber
    INTO e_remark
    WHERE vbpa~vbeln = i_remito-entrega
    AND vbpa~parvw EQ 'IC'.


ENDMETHOD.
