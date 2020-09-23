sap.ui.define([
	"sap/ui/core/mvc/Controller"
], function (Controller) {
	"use strict";

	return Controller.extend("softtek.nevegacion.controller.vista1", {
		onInit: function () {

		},
		
		navegar: function(oEvent){
			
			var nombre = this.byId("nombre").getValue();
			this.getOwnerComponent().getRouter( ).navTo("Routevista2", 
			{
				Nombre: nombre,
				String: "Este es mi string"
			});
		}
	});
});