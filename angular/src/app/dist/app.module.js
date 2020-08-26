"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
exports.__esModule = true;
exports.AppModule = void 0;
var core_1 = require("@angular/core");
var platform_browser_1 = require("@angular/platform-browser");
var http_1 = require("@angular/common/http");
var app_component_1 = require("./app.component");
var home_component_1 = require("./serverless-login/home.component");
var app_routing_module_1 = require("./app-routing.module");
var heroes_component_1 = require("./heroes/heroes.component");
var lightswitch_component_1 = require("./lightswitch/lightswitch.component");
var forms_1 = require("@angular/forms");
var hero_detail_component_1 = require("./hero-detail/hero-detail.component");
var hero_service_1 = require("./heroes/hero.service");
var config_component_1 = require("./config/config.component");
var page_not_found_component_1 = require("./page-not-found/page-not-found.component");
var AppModule = /** @class */ (function () {
    function AppModule() {
    }
    AppModule = __decorate([
        core_1.NgModule({
            declarations: [
                app_component_1.AppComponent,
                home_component_1.HomeComponent,
                heroes_component_1.HeroesComponent,
                lightswitch_component_1.LightswitchComponent,
                hero_detail_component_1.HeroDetailComponent,
                config_component_1.ConfigComponent,
                page_not_found_component_1.PageNotFoundComponent
            ],
            imports: [
                platform_browser_1.BrowserModule,
                // import this after BrowserModule as per https://angular.io/guide/http
                http_1.HttpClientModule,
                forms_1.FormsModule,
                app_routing_module_1.AppRoutingModule
            ],
            providers: [hero_service_1.HeroService],
            bootstrap: [app_component_1.AppComponent]
        })
    ], AppModule);
    return AppModule;
}());
exports.AppModule = AppModule;
