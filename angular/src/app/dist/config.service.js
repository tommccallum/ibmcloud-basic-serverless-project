"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
exports.__esModule = true;
exports.ConfigService = void 0;
var core_1 = require("@angular/core");
var rxjs_1 = require("rxjs");
var operators_1 = require("rxjs/operators");
var ConfigService = /** @class */ (function () {
    function ConfigService(http) {
        this.http = http;
        this.configUrl = 'assets/config.json';
    }
    ConfigService.prototype.getConfig = function () {
        return this.http.get(this.configUrl).pipe(operators_1.retry(3), // retry a failed request up to 3 times
        operators_1.catchError(this.handleError) // then handle the error
        );
    };
    ConfigService.prototype.getConfigResponse = function () {
        return this.http.get(this.configUrl, { observe: 'response' });
    };
    ConfigService.prototype.handleError = function (error) {
        if (error.error instanceof ErrorEvent) {
            // A client-side or network error occurred. Handle it accordingly.
            console.error('An error occurred:', error.error.message);
        }
        else {
            // The backend returned an unsuccessful response code.
            // The response body may contain clues as to what went wrong.
            console.error("Backend returned code " + error.status + ", " +
                ("body was: " + error.error));
        }
        // Return an observable with a user-facing error message.
        return rxjs_1.throwError('Something bad happened; please try again later.');
    };
    ConfigService = __decorate([
        core_1.Injectable()
    ], ConfigService);
    return ConfigService;
}());
exports.ConfigService = ConfigService;
