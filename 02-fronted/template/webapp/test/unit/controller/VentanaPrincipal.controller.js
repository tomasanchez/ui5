/*global QUnit*/

sap.ui.define([
	"softtek/primerproyecto/controller/VentanaPrincipal.controller"
], function (Controller) {
	"use strict";

	QUnit.module("VentanaPrincipal Controller");

	QUnit.test("I should test the VentanaPrincipal controller", function (assert) {
		var oAppController = new Controller();
		oAppController.onInit();
		assert.ok(oAppController);
	});

});