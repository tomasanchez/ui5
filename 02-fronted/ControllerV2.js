sap.ui.define([
	"sap/ui/core/mvc/Controller",
	"sap/m/MessageToast",
	'sap/ui/model/odata/v2/ODataModel'
], function (Controller, MessageToast, ODataModel) {
	"use strict";
	var oController;
	var oLastClient;
	return Controller.extend("TOSA8.MyGym.controller.View1", {
		onInit: function () {

			oController = this;
			
			// Set the initial form to be the display one
		},
		
		handleEditPress: function(oEvent){
			
			//Enabling Editing
			oController._enableEdits(true);
			oController._toggleButtonsAndView(true);
		},
		
		handleCancelPress : function () {
			//Restore the data
			oController.loadClient(oLastClient);
			oController._toggleButtonsAndView(false);
			oController._enableEdits(false);
		},
		
		handleSavePress : function () {
			
			
			var client = oLastClient;
			oController._getNewClientData(client);
			
			oLastClient = client;
			
			oController.onEditClient(client);
			oController.refreshClients();
			
			oController._toggleButtonsAndView(false);
			oController._enableEdits(false);
		},
		
		_enableEdits: function(active){
			//Enabling all
			oController.byId("clientName").setEditable(active);
			oController.byId("clientName").setEditable(active);
			oController.byId("clientLastName").setEditable(active);
			oController.byId("clientCP").setEditable(active);
			oController.byId("clientTel").setEditable(active);
			oController.byId("clientStreet").setEditable(active);
		},
		
		_toggleButtonsAndView : function (bEdit) {
	
			// Show the appropriate action buttons
			oController.byId("edit").setVisible(!bEdit);
			oController.byId("save").setVisible(bEdit);
			oController.byId("cancel").setVisible(bEdit);
		},
		
		onItemSelected: function(oEvent) {
				var oItem = oEvent.getSource();
				MessageToast.show(
					'Item ' + oItem.getName() + " was selected"
				);
			},
		
		onEditClient : function (oClient){
		
			var oModelDefault = this.getView().getModel();
			
			//Create Key
			var sPath = oModelDefault.createKey("/ClientesSet", {
				IdClte: oClient.IdClte
			});
			
			var oEntity = {
				IdClte: oClient.IdClte,
				Nombre: oClient.Nombre,
				Apellido: oClient.Apellido,
				Post: oClient.Post,
				Telf: oClient.Telf,
				Calle: oClient.Calle
			};
			
			oController.getView().setBusy(true);
			
			oModelDefault.update(sPath, oEntity, {
				success: function (resultado) {
					oController.getView().setBusy(false);
					//MessageToast.show( "Descripcion: " + resultado.Descripcion);
				}.bind(this),
				error: function (error) {
					MessageToast.show("Error");
					oController.getView().setBusy(false);
				}
			});
		},
		
		refreshClients: function(oEvent){
			var oModel = oController.getView().getModel();
			oModel.read("/ClientesSet",{
				success: function (resultado) {
					MessageToast.show("Success");
					var modeloJSON = new sap.ui.model.json.JSONModel(resultado.results);
					oController.getView().setModel( modeloJSON);
				}.bind(this),
				error: function (error) {
					MessageToast.show("Error");
				}
			});
			
		},
		
		onPressClient: function(oEvent){
			//Tomo el modelo de la lista
			var oModelDefault = this.getView().getModel();
			
			//Busco la referencia del registro seleccionado
			var keyClte = oEvent.getSource().getBindingContext().getProperty("IdClte");
			
			var sPath = oModelDefault.createKey("/ClientesSet", {
				IdClte: keyClte
			});
			
			oModelDefault.read(sPath, {
				success: function (result) {
					this.getClientSports(sPath);
					this.loadClient(result);
				}.bind(this),
				error: function (error) {
					MessageToast.show("Error");
				}
			}
			);
			
		},
		
		loadClient: function(result){
			oLastClient = result;
			oController.byId("clientID").setValue(result.IdClte);
			oController.byId("clientName").setValue(result.Nombre);
			oController.byId("clientLastName").setValue(result.Apellido);
			oController.byId("clientCP").setValue(result.Post);
			oController.byId("clientTel").setValue(result.Telf);
			oController.byId("clientStreet").setValue(result.Calle);
		},
		
		_getNewClientData: function(newClient){
			newClient.Nombre = oController.byId("clientName").getDOMValue();
			newClient.Apellido = oController.byId("clientLastName").getDOMValue();
			newClient.Post = oController.byId("clientCP").getDOMValue();
			newClient.Telf = oController.byId("clientTel").getDOMValue();
			newClient.Calle = oController.byId("clientStreet").getDOMValue();
		},
		
		getClientSports : function(Path){
			var oModel = this.getView().getModel();
			
			oModel.read(Path + "/nDeportes",{
				success: function (result) {
					this.loadClientSport(result);
				}.bind(this),
				error: function (error) {
					MessageToast.show("Error");
				}
			});
		},
		
		loadClientSport : function (resultArray){
			var modelJSON = new sap.ui.model.json.JSONModel(resultArray.results);
			this.byId("csportsTable").setModel(modelJSON, "oneClientSports");
		}
		
	});
});