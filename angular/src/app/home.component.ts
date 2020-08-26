
import {map} from 'rxjs/operators';
import { Component } from '@angular/core';
import { ActivatedRoute, Params, Router } from '@angular/router';
import { Http, Headers, URLSearchParams, RequestOptions } from '@angular/http';
import * as config from '../assets/config.json';
import { Observable } from 'rxjs';
import 'rxjs/Rx';
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
@Component({
  selector: 'ibm-serverless-login',
  templateUrl: './home.component.html'
})

export class HomeComponent {

  private initialized: boolean = false;
  private redirectUrl: string;
  private authorizationUrl: string;
  private clientId: string;
  private protectedUrl: string;

  private accessToken: string;
  private refreshToken: string;
  private expiresIn: string;
  private userName: string;
  private resultOfProtectedAPI;
  // private jsonResultOfProtectedAPI: JSON;
  
  onButtonLoginClicked(): void {

    if (this.initialized == true) {
      let url = this.authorizationUrl + "?response_type=" + "code";
      url = url + "&client_id=" + this.clientId;
      url = url + "&redirect_uri=" + this.redirectUrl;
      window.location.href = url;
    }
  }

  onButtonInvokeActionClicked(): void {

    let headers = new Headers({
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ' + this.accessToken,
      'X-Debug-Mode': true
    });
    let options = new RequestOptions({ headers: headers });

    this.http.get(this.protectedUrl, options).pipe(
      map(res => res.json()))
      .subscribe(
        result => {
          console.log(result)
          // this.jsonResultOfProtectedAPI = result;
          this.resultOfProtectedAPI = JSON.stringify(result, null, 2);
        },
        err => {
          console.error(err);
          // this.jsonResultOfProtectedAPI = null;
          this.resultOfProtectedAPI = JSON.stringify(err, null, 2);
        });
  }

  constructor(
    // Notice here that we create and initialise the class members
    // http, route and router all in one place.
    // This style is part of the typescript functionality.
    private http: Http,
    private route: ActivatedRoute,
    private router: Router) {
  }

  ngOnInit(): void {
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
    if (this.accessToken) console.log(this.accessToken)
    this.refreshToken = this.route.snapshot.queryParams["refresh_token"];
    if (this.refreshToken) console.log(this.refreshToken)
    this.expiresIn = this.route.snapshot.queryParams["expires_in"];
    if (this.expiresIn) console.log(this.expiresIn)
    this.userName = this.route.snapshot.queryParams["user_name"];
    if (this.userName) console.log(this.userName)
  }

}

