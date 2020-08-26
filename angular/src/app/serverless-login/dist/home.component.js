"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
exports.__esModule = true;
exports.HomeComponent = void 0;
var core_1 = require("@angular/core");
//RequestOptions, XHRBackend
// , URLSearchParams, RequestOptions 
// Headers
var http_1 = require("@angular/common/http");
var config_json_1 = require("../../assets/config.json");
require("rxjs/Rx");
// import { PipeTransform, Pipe } from '@angular/core';
// @Pipe({name: 'keys'})
// export class KeysPipe implements PipeTransform {
//   transform(value: any, args:string[]) : any {
//     let keys = [];
//     for (let key in value) {
//       keys.push(key);
//     }
//     return keys;
//   }
// }
var HomeComponent = /** @class */ (function () {
    function HomeComponent(
    // Notice here that we create and initialise the class members
    // http, route and router all in one place.
    // This style is part of the typescript functionality.
    httpClient, route, router) {
        this.httpClient = httpClient;
        this.route = route;
        this.router = router;
        this.initialized = false;
    }
    // private jsonResultOfProtectedAPI: JSON;
    HomeComponent.prototype.onButtonLoginClicked = function () {
        if (this.initialized == true) {
            var url = this.authorizationUrl + "?response_type=" + "code";
            url = url + "&client_id=" + this.clientId;
            url = url + "&redirect_uri=" + this.redirectUrl;
            window.location.href = url;
        }
    };
    HomeComponent.prototype.onButtonInvokeActionClicked = function () {
        var _this = this;
        var headers = new http_1.HttpHeaders({
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ' + this.accessToken,
            'X-Debug-Mode': "true"
        });
        var options = { headers: headers };
        this.httpClient.get(this.protectedUrl, options)
            .subscribe(function (result) { return _this.resultOfProtectedAPI = JSON.stringify(result, null, 2); }, function (error) { return _this.resultOfProtectedAPI = JSON.stringify(error, null, 2); });
    };
    HomeComponent.prototype.ngOnInit = function () {
        // This is a hook into the Angular Component lifecycle.
        // This function is called after the constructor and after the first ngOnChanges().
        this.redirectUrl = config_json_1["default"]['redirectUrl'];
        this.authorizationUrl = config_json_1["default"]['authorizationUrl'] + "/authorization";
        this.clientId = config_json_1["default"]['clientId'];
        this.protectedUrl = config_json_1["default"]['protectedUrl'];
        this.initialized = true;
        // Notice that we are getting parameters from the query string
        // that is anything after the question mark (?) in the url.
        // We can use the this.route.snapshot method here to access
        // the query parameters as we don't intend to modify them.
        this.accessToken = this.route.snapshot.queryParams["access_token"];
        this.refreshToken = this.route.snapshot.queryParams["refresh_token"];
        this.expiresIn = this.route.snapshot.queryParams["expires_in"];
        this.userName = this.route.snapshot.queryParams["user_name"];
        if (this.accessToken)
            console.log(this.accessToken);
        if (this.refreshToken)
            console.log(this.refreshToken);
        if (this.expiresIn)
            console.log(this.expiresIn);
        if (this.userName)
            console.log(this.userName);
    };
    HomeComponent = __decorate([
        core_1.Component({
            selector: 'ibm-serverless-login',
            templateUrl: './home.component.html'
        })
    ], HomeComponent);
    return HomeComponent;
}());
exports.HomeComponent = HomeComponent;
