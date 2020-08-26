import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { HttpClientModule, RequestOptions, XHRBackend, HttpClient } from "@angular/http";
import { AppComponent } from './app.component';
import { HomeComponent } from './home.component';
import { routing, appRoutingProviders } from './app.routing';
import { HeroesComponent } from './heroes/heroes.component';
import { LightswitchComponent } from './lightswitch.component';
import { FormsModule } from '@angular/forms';
import { HeroDetailComponent } from './hero-detail/hero-detail.component';
import { HeroService } from './hero.service'

@NgModule({
  declarations: [
    AppComponent, HomeComponent, HeroesComponent, LightswitchComponent, HeroDetailComponent
  ],
  imports: [
    HttpClientModule,
    BrowserModule,
    FormsModule,
    routing
  ],
  providers: [appRoutingProviders, HeroService],
  bootstrap: [AppComponent]
})
export class AppModule { }
