import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { HomeComponent } from './serverless-login/home.component';
import { PageNotFoundComponent } from './page-not-found/page-not-found.component';
import { LightswitchComponent } from './lightswitch/lightswitch.component';
import { HeroesComponent } from './heroes/heroes.component';

// The order of routes is important because the Router uses a first-match wins strategy 
// when matching routes, so more specific routes should be placed above less specific routes. 
// List routes with a static path first, followed by an empty path route, which matches the 
// default route. The wildcard route comes last because it matches every URL and the Router 
// selects it only if no other routes match first.
const routes: Routes = [
  { path: 'home', component: HomeComponent, pathMatch: 'full' },
  { path: 'lightswitch', component: LightswitchComponent, pathMatch: 'full' },
  { path: 'heroes', component: HeroesComponent, pathMatch: 'full' },
  { path: 'page-not-found', component: PageNotFoundComponent, pathMatch: 'full' },
  { path: '', redirectTo: "home", pathMatch: "full"  }, // do not use /home or you lose the query parameters
  { path: '**', component: PageNotFoundComponent }
];

// configures NgModule imports and exports
@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }