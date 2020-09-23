/*global QUnit*/

sap.ui.define([
	"softtek/nevegacion/controller/vista1.controller"
], function (Controller) {
	"use strict";

	QUnit.module("vista1 Controller");

	QUnit.test("I should test the vista1 controller", function (assert) {
		var oAppController = new Controller();
		oAppController.onInit();
		assert.ok(oAppController);
	});

});