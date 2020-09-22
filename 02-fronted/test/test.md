# Test

## Table with Name / Surname / ID

```xml
<Table items="{oneClient/}" noDataText="Seleccione un cliente">
<!--<Table items="{/VueloSet}">-->
	<columns>			
		<Column hAlign="Begin" width="16rem">
			<header>
				<Text text="Nro de cliente"/>
			</header>
		</Column>
						
		<Column hAlign="Begin" width="16rem">
			<header>
				<Text text="Nombre"/>
			</header>
		</Column>
						
		<Column hAlign="Begin" width="16rem">
			<header>
				<Text text="Apellido"/>
			</header>
		</Column>
    </columns>
					
	<items>
		<ColumnListItem>
			<cells>
				<ObjectIdentifier text="{oneClient>IdClte}"/>
				<ObjectIdentifier text="{oneClient>Nombre}"/>
				<ObjectIdentifier text="{oneClient>Apellido}"/>
			</cells>
	    </ColumnListItem>
	</items>
</Table>
```

## Lista + Borrar

```xml
<List id="clientList" 
	mode="Delete"
	delete="handleDelete"
	growing="true"
	headerText="Clientes"
	items="{/ClientesSet}" sticky="ColumnHeaders">
</List>
```

```js
handleDelete: function(oEvent) {
    var oList = oEvent.getSource(),
	oItem = oEvent.getParameter("clientItem"),
	sPath = oItem.getBindingContext().getPath();

	// after deletion put the focus back to the list
	oList.attachEventOnce("updateFinished", oList.focus, oList);

	// send a delete request to the odata service
this.oProductModel.remove(sPath);
}
```

```js
//Al traer entity_set debemos usar result.results
loadClientSport : function (resultArray){
			var modelJSON = new sap.ui.model.json.JSONModel(resultArray.results);
			this.getView().byId("csportsTable").setModel(modelJSON, "oneClientSports");
		}
```
