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
var http_1 = require("@angular/http");
var config = require("../assets/config.json");
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
    http, route, router) {
        this.http = http;
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
        var headers = new http_1.Headers({
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ' + this.accessToken,
            'X-Debug-Mode': true
        });
        var options = new http_1.RequestOptions({ headers: headers });
        this.http.get(this.protectedUrl, options)
            .map(function (res) { return res.json(); })
            .subscribe(function (result) {
            console.log(result);
            // this.jsonResultOfProtectedAPI = result;
            _this.resultOfProtectedAPI = JSON.stringify(result, null, 2);
        }, function (err) {
            console.error(err);
            // this.jsonResultOfProtectedAPI = null;
            _this.resultOfProtectedAPI = JSON.stringify(err, null, 2);
        });
    };
    HomeComponent.prototype.ngOnInit = function () {
        // This is a hook into the Angular Component lifecycle.
        // This function is called after the constructor and after the first ngOnChanges().
        this.redirectUrl = config['redirectUrl'];
        this.authorizationUrl = config['authorizationUrl'] + "/authorization";
        this.clientId = config['clientId'];
        this.protectedUrl = config['protectedUrl'];
        this.initialized = true;
        // Notice that we are getting parameters from the query string
        // that is anything after the question mark (?) in the url.
        this.accessToken = this.route.snapshot.queryParams["access_token"];
        if (this.accessToken)
            console.log(this.accessToken);
        this.refreshToken = this.route.snapshot.queryParams["refresh_token"];
        if (this.refreshToken)
            console.log(this.refreshToken);
        this.expiresIn = this.route.snapshot.queryParams["expires_in"];
        if (this.expiresIn)
            console.log(this.expiresIn);
        this.userName = this.route.snapshot.queryParams["user_name"];
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
