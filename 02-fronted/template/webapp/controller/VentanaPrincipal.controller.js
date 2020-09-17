sap.ui.define([
	"sap/ui/core/mvc/Controller",
	"sap/m/MessageToast"
], function (Controller, MessageToast) {
	"use strict";

	return Controller.extend("softtek.primerproyecto.controller.VentanaPrincipal", {
		onInit: function () {
			
		},

		armarJSON: function () {
			var json = {
				CAMPO: "VALOR",
				muchosCampos: [{
					campo: "campoos 1"
				}, {
					campo: "campoos 2"
				}]
			};
		},

		onPressBoton: function (oEvent) {
			
			this.buscarVuelos();

			//sap.m.MessageBox.show("Hola");

		},
		
		
		buscarVuelos: function(){
			
			
			var oModel = this.getView().getModel();

			oModel.read("/VueloSet", {
				success: function (resultado) {
					MessageToast.show("Exito");
					this.cargarModelo(resultado.results);
				}.bind(this),
				error: function (error) {
					MessageToast.show("Error");
				}
			});
		},
		
		
		onPressLeerVuelo: function(oEvent){
			var oModel = this.getView().getModel();
			var inputVuelo = this.getView().byId("vuelo");
			
			var nroVuelo = inputVuelo.getValue();
			
			var sPath = oModel.createKey("/VueloSet", {
				Idvuelo: nroVuelo
			});
			
			oModel.read(sPath, {
				success: function (resultado) {
					MessageToast.show( "Descripcion: " + resultado.Descripcion);
				}.bind(this),
				error: function (error) {
					MessageToast.show("Error");
				}
			});
		},
		
		onEditVuelo:function(oEvent){
			
			var oModel = this.getView().getModel("NUEVOMODELO");
			
			//Busco la referencia del registro seleccionado
			var oBinding = oEvent.getSource( ).getParent( ).getBindingContextPath();
			var oObject = oModel.getProperty( oBinding );
			
			//Busco el modelo default
			var oModelDefault = this.getView().getModel();
			
			var nroVuelo = oObject.Idvuelo;
			var sPath = oModelDefault.createKey("/VueloSet", {
				Idvuelo: nroVuelo
			});
			
			var oEntidad = { 
				Idvuelo: nroVuelo,
				Descripcion: oObject.Descripcion,
				Calidad: "1"
			};
			
			this.getView().setBusy(true);
			
			oModelDefault.update(sPath, oEntidad, {
				success: function (resultado) {
					this.getView().setBusy(false);
					//MessageToast.show( "Descripcion: " + resultado.Descripcion);
				}.bind(this),
				error: function (error) {
					MessageToast.show("Error");
					this.getView().setBusy(false);
				}
			});
			
			
		},
		
		onDeleteVuelo: function(oEvent){
			
			var oModel = this.getView().getModel("NUEVOMODELO");
			
			//Busco la referencia del registro seleccionado
			var oBinding = oEvent.getSource( ).getParent( ).getBindingContextPath();
			var oObject = oModel.getProperty( oBinding );
			
			//Busco el modelo default
			var oModelDefault = this.getView().getModel();
			
			var nroVuelo = oObject.Idvuelo;
			var sPath = oModelDefault.createKey("/VueloSet", {
				Idvuelo: nroVuelo
			});
		
			
			this.getView().setBusy(true);
			
			oModelDefault.remove(sPath, {
				success: function (resultado) {
					this.getView().setBusy(false);
					this.refrescarTabla();
				}.bind(this),
				error: function (error) {
					MessageToast.show("Error");
					this.getView().setBusy(false);
				}
			});
			
		},
		
		refrescarTabla: function(oEvent){
			this.buscarVuelos( );
			
			//Limpiar tabla
			//var modeloJSON = new sap.ui.model.json.JSONModel( {} );
			//this.getView().setModel( modeloJSON, "NUEVOMODELO" );
			
		},
		
		onMostrarFlujo: function(oEvent){
			
			var oModel = this.getView().getModel("NUEVOMODELO");
			
			//Busco la referencia del registro seleccionado
			var oBinding = oEvent.getSource( ).getParent( ).getBindingContextPath();
			var oObject = oModel.getProperty( oBinding );
			
			//Busco el modelo default
			var oModelDefault = this.getView().getModel();
			
			var nroVuelo = oObject.Idvuelo;
			var sPath = oModelDefault.createKey("/VueloSet", {
				Idvuelo: nroVuelo
			});
			
			oModelDefault.read(sPath + "/FlujoVueloSet", {
				success: function (resultado) {
					this.cargarModeloFlujo(resultado.results);
				}.bind(this),
				error: function (error) {
					
				}
			});
			
		},
		
		
		onPressCrearVuelo: function(oEvent){
			
			var oModelDefault = this.getView().getModel();
			
			var oEntidad = { 
				Idvuelo: "1235",
				Descripcion: "Nuevo Vuelo",
				Calidad: "9"
				/*Flujo: [ {
					Estado: "pendiente"
				},{
					Estado: "otro"
				}
				]*/
			};
			
			this.getView().setBusy(true);
			
			oModelDefault.create("/VueloSet", oEntidad, {
				success: function (resultado) {
					this.getView().setBusy(false);
					
				}.bind(this),
				error: function (error) {
					MessageToast.show("Error");
					this.getView().setBusy(false);
				}
			});
			
		},
		
		cargarModeloFlujo: function(arrayResultado){
			
			
			//var modeloJSON = new sap.ui.model.json.JSONModel(arrayResultado);
			var modeloJSON = new sap.ui.model.json.JSONModel(arrayResultado);
			this.getView().setModel( modeloJSON, "Flujo" );
		},
		
		cargarModelo: function(arrayResultado){
			
			var nuevoResultado = []; //Lista de objetos
			arrayResultado.forEach( function(item){
				//if((item.Calidad === "5")||(item.Calidad === "4"))
				if(item.Calidad === "9")
					nuevoResultado.push(item);
			}.bind(this));
			
			
			//var modeloJSON = new sap.ui.model.json.JSONModel(arrayResultado);
			var modeloJSON = new sap.ui.model.json.JSONModel(nuevoResultado);
			this.getView().setModel( modeloJSON, "NUEVOMODELO" );
		},
		
		onPressBotonError: function (oEvent) {
			//sap.m.MessageBox.error("Error");
		}
	});
});