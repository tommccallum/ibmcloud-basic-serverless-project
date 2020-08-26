"use strict";
exports.__esModule = true;
var testing_1 = require("@angular/core/testing");
var config_service_1 = require("./config.service");
describe('ConfigService', function () {
    var service;
    beforeEach(function () {
        testing_1.TestBed.configureTestingModule({});
        service = testing_1.TestBed.inject(config_service_1.ConfigService);
    });
    it('should be created', function () {
        expect(service).toBeTruthy();
    });
});
