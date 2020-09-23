sap.ui.define([
	"sap/ui/core/mvc/Controller",
	"sap/ui/core/routing/History"
], function (Controller,History) {
	"use strict";

	return Controller.extend("softtek.nevegacion.controller.vista2", {


		onInit: function () {
			var routerVista2 = this.getOwnerComponent( ).getRouter().getRoute("Routevista2");
			
			routerVista2.attachPatternMatched(this._onObjectMatched, this);
			
			//Genera nueva instancia de Route
			/*var RoutePropio = sap.ui.core.UIComponent.getRouteFor(this);
			RoutePropio.attachRouteMatched(this._onObjectMatched, this);*/
		},
		
		onNavBack:function(oEvent){
			//volver
			this.getOwnerComponent().getRouter( ).navTo("");

		},

		_onObjectMatched: function (oEvent) {
			
			var nombre =  oEvent.getParameter("arguments").Nombre;
			var string =  oEvent.getParameter("arguments").String;
			sap.m.MessageBox.show(nombre + string);
			//sap.m.MessageBox.error();
			
			//oModel.read("traeme todo de NOMBRE"){}
			
			/*this.getModel().metadataLoaded().then( function() {
				var sObjectPath = this.getModel().createKey("PurchaseOrderSet", {
					Ebeln :  sObjectId
				});
				this._bindView("/" + sObjectPath);
			}.bind(this));*/
			
			
		}

		/**
		 * Called when the View has been rendered (so its HTML is part of the document). Post-rendering manipulations of the HTML could be done here.
		 * This hook is the same one that SAPUI5 controls get after being rendered.
		 * @memberOf softtek.nevegacion.view.vista2
		 */
		//	onAfterRendering: function() {
		//
		//	},

		/**
		 * Called when the Controller is destroyed. Use this one to free resources and finalize activities.
		 * @memberOf softtek.nevegacion.view.vista2
		 */
		//	onExit: function() {
		//
		//	}

	});

});