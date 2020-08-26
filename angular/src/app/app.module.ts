import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { HttpClientModule, HttpClient } from "@angular/common/http";
import { AppComponent } from './app.component';
import { HomeComponent } from './serverless-login/home.component';
import { AppRoutingModule } from './app-routing.module';
import { HeroesComponent } from './heroes/heroes.component';
import { LightswitchComponent } from './lightswitch/lightswitch.component';
import { FormsModule } from '@angular/forms';
import { HeroDetailComponent } from './hero-detail/hero-detail.component';
import { HeroService } from './heroes/hero.service';
import { ConfigComponent } from './config/config.component';
import { PageNotFoundComponent } from './page-not-found/page-not-found.component'

@NgModule({
  declarations: [
    AppComponent, 
    HomeComponent, 
    HeroesComponent, 
    LightswitchComponent, 
    HeroDetailComponent, 
    ConfigComponent, 
    PageNotFoundComponent
  ],
  imports: [
    BrowserModule,
    // import this after BrowserModule as per https://angular.io/guide/http
    HttpClientModule,
    FormsModule,
    AppRoutingModule
  ],
  providers: [HeroService],
  bootstrap: [AppComponent]
})
export class AppModule { }
