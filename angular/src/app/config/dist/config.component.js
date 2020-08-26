"use strict";
var __assign = (this && this.__assign) || function () {
    __assign = Object.assign || function(t) {
        for (var s, i = 1, n = arguments.length; i < n; i++) {
            s = arguments[i];
            for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p))
                t[p] = s[p];
        }
        return t;
    };
    return __assign.apply(this, arguments);
};
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
exports.__esModule = true;
exports.ConfigComponent = void 0;
var core_1 = require("@angular/core");
var config_service_1 = require("./config.service");
var ConfigComponent = /** @class */ (function () {
    function ConfigComponent(configService) {
        this.configService = configService;
    }
    ConfigComponent.prototype.showConfig = function () {
        var _this = this;
        this.configService.getConfig()
            // clone the data object, using its known Config shape
            .subscribe(function (data) { return _this.config = __assign({}, data); });
    };
    ConfigComponent.prototype.showConfigResponse = function () {
        var _this = this;
        this.configService.getConfigResponse()
            // resp is of type `HttpResponse<Config>`
            .subscribe(function (resp) {
            // display its headers
            var keys = resp.headers.keys();
            _this.headers = keys.map(function (key) {
                return key + ": " + resp.headers.get(key);
            });
            // access the body directly, which is typed as `Config`.
            _this.config = __assign({}, resp.body);
        });
    };
    ConfigComponent.prototype.ngOnInit = function () {
    };
    ConfigComponent = __decorate([
        core_1.Component({
            selector: 'app-config',
            templateUrl: './config.component.html',
            styleUrls: ['./config.component.css'],
            providers: [config_service_1.ConfigService]
        })
    ], ConfigComponent);
    return ConfigComponent;
}());
exports.ConfigComponent = ConfigComponent;
