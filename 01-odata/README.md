# 01 - Odatas

Odatas se basan en el modelo **CRUD**: *Create*, *Read*, *Update* and *Delete*. Podemos asimilarlo a un objeto con unicamente los metodos que respeten el modelo.

Nro transaccion :: **segw**

Nomenclatura: ZOS_CA_USER_ACADEMIA.. Descripcion : Servicio Academia 2020.

Primero a definir: son las *entidades*, creando a su vez los *related entity sets*.

Al crearse un odata, se crean dos clases:

1. **MPC** Donde se hacen las declaraciones.
   - **MPC_EXT**, del momento no importa.
2. **DPC** Las definiciones, tienen los metodos *CRUD*.
   - **DPC_EXT**, donde vamos a codificar.

Estas apareceran en *Artefacts*, codigo abap auto-generado.

Definimos las asociaciones para generar las *Navegation Properties*.

## Implementando Metodos

**GET_ENTITITY_SET**

```ABAP
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
```

**GET_ENTITY**

```ABAP
method MY-ENTITY_GET_ENTITY.

DATA: is_key_tab LIKE LINE OF it_key_tab,
    lv_value    LIKE ZTCA_MY-TABLE~Key.

IF sy-subrc EQ 0.
    lv_key = ls_key_tab~value.

READ TABLE

    SELECT * FROM ZTCA_MY-TABLE
        "Por si no estan todos los datos, el corresponding evalua los que si."
        INTO CORRESPENDIG FIELDS OF ER_ENTITY
        WHERE key EQ lv_key

end method.
```

## Implementando el Flujo

**GET_ENTITY**, busco devolver un elemento.

```ABAP
method MY-FLUJO_GET_ENTITY.

DATA: is_key_tab LIKE LINE OF it_key_tab,
    lv_value    TYIPE ZTCA_MY-FLUJO~Key,
    lv_status   TYPE ZTCA_MY-FLUJO~status.

IF sy-subrc EQ 0.
    lv_key = ls_key_tab~value.

READ TABLE

    SELECT * FROM ZTCA_MY-FLUJO
        "Por si no estan todos los datos, el corresponding evalua los que si."
        INTO CORRESPENDIG FIELDS OF ER_ENTITY
        WHERE key   EQ lv_key,
            status  EQ lv_status.

end method.
```

**GET_ENTITY-SET**, busco devolver una tabla.

```ABAP
method MY-FLUJO_GET_ENTITY_SET.

DATA: is_key_tab LIKE LINE OF it_key_tab,
    lv_value    TYIPE ZTCA_MY-FLUJO~Key,
    lv_status   TYPE ZTCA_MY-FLUJO~status.

IF sy-subrc EQ 0.
    lv_key = ls_key_tab~value.
END IF.


READ TABLE it_key_tab INTI lv_key WITH KEY 'ID_key'.

IF sy-subrc EQ 0.
    SELECT * FROM ZTCA_MY-FLUJO.
   
        "Por si no estan todos los datos, el corresponding evalua los que si."
        INTO CORRESPENDIG FIELDS OF ER_ENTITY
        WHERE key   EQ lv_key,
            status  EQ lv_status.


END IF.

end method.
```

## Publicando Servicios oData

Transaccion ```/n/iwfnd/maint_services```

Utilizar -> Alias :: LOCAL.

## JavaScript

###  Master detail

Para crear necesitamos:

```xml

<SplitApp id="THS_ID" initialMaster="master_id">
		<masterPages>
			<Page title="My Gym" id="master_id" class="sapUiStdPage">
			</Page>
		</masterPages>
	</SplitApp>
```
