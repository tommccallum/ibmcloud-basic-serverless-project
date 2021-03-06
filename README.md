# Serverless Web Applications on the IBM Cloud

This repo explains how to build and run serverless web applications on the IBM Cloud. Business logic is implemented with IBM Cloud Functions, static web resources are stored in IBM Object Storage, authentication is handled via IBM App ID and data is stored in the managed NoSQL database IBM Cloudant.

The project contains a sample web application built with Angular which requires user authentication to access data in Cloudant. Watch the 10 seconds [video](documentation/serverless-web-app.mp4) for a short demo.

While the Angular application and the protected API are samples, the other components in this repo are generic and can be reused for other web applications, for example the login functionality and the setup of App ID, Cloudant and Object Storage.

This diagram describes the architecture with the main components:

![alt text](documentation/serverless-web-app.png "architecture diagram")



Find out more about the main components:

* [IBM Cloud Functions](https://cloud.ibm.com/openwhisk) powered by Apache OpenWhisk
* [IBM Cloud Functions API Management](https://cloud.ibm.com/openwhisk/apimanagement)
* [IBM Cloud Object Storage](https://cloud.ibm.com/catalog/services/cloud-object-storage)
* [IBM App ID](https://cloud.ibm.com/catalog/services/app-id)
* [IBM Cloudant](https://cloud.ibm.com/catalog/services/cloudant)

## Outline

- [Serverless Web Applications on the IBM Cloud](#serverless-web-applications-on-the-ibm-cloud)
  - [Outline](#outline)
  - [Prerequisites](#prerequisites)
  - [Installing Angular CLI (ng)](#installing-angular-cli-ng)
  - [Setup the environment](#setup-the-environment)
  - [To remove all services](#to-remove-all-services)
  - [When things go wrong...](#when-things-go-wrong)
  - [Run locally](#run-locally)
  - [What does what?](#what-does-what)
  - [Credits](#credits)

## Prerequisites

Create an IBM Cloud lite account (free, no credit card required):

* You will require an Academic Initiative account from your institution.

Make sure you have the following tools installed:

* Install the helper scripts available from [IBM Cloud Scripts](https://github.com/tommccallum/ibmcloud-scripts) 
* [git](https://git-scm.com/downloads)
* [ibmcloud CLI](https://console.bluemix.net/docs/cli/index.html)
* [node](https://nodejs.org/en/download/)
* [curl](https://curl.haxx.se/download.html)
* [ng](https://github.com/angular/angular-cli/wiki) (only needed for the Angular sample application)

This assumes you are running a version of Linux or similar.

## Installing Angular CLI (ng)

```
sudo npm install -g @angular/cli
```

## Setup the environment

Invoke the following commands:

```
$ git clone git@github.com:tommccallum/ibmcloud-basic-serverless-project.git
$ cd serverless-basic-serverless-project
$ ibm_login.sh
$ ./build_all.sh
```

The final URL will be presented to you.  Copy and paste this into your browser.  For example:

```
Done! Open your app: https://service.eu.apiconnect.ibmcloud.com/gws/apigateway/api/f480843e14eb28dfb6c273dd4638dbbf5cef56da97581b5a76fff44bfa5f9c50/serverlessweb/web
```

The credentials user@demo.email, verysecret will let you in or you can try using your Google or Facebook credentials.

## To remove all services

```
./delete-resources.sh
```

## When things go wrong...

Check out the logs in the scripts directory when something goes wrong.  The build_all.sh script will warn you if the world "FAILED" appears in any of the logs and stop at the stage that had the error.

You can search for errors with the following:

```
grep -nH "FAILED" scripts/*.log
```

The -n adds line numbers and the -H shows the file the pattern appeared in.

## Run locally

```
cd angular
ng serve
```

Open http://localhost:4200 in your browser.

## What does what?

* the _angular_ directory contains our app assets including HTML, CSS and all the javascript.
* the _documentation_ directory is the additional documentation that came with this repository
* the _function-html_ directory as the javascript code for the serverless function 'html'.  It also contains the swagger file that defines the API to reach the serverless function.
* the _function-login_ directory as the javascript code for the serverless functions 'login', 'redirect' and 'login-and-redirect'.  It also contains the swagger file that defines the API to reach these serverless functions.
* the _function-protected_ directory as the javascript code for the serverless function 'function-protected'.  It also contains the swagger file that defines the API to reach the serverless function.
* the _node_modules_ directory is where npm caches its files and will be created upon build.
* the _scripts_ contains all the build scripts for the various services this project uses.
* the _local.env_ file is created for each new build and contains the environment variables for the bash scripts in _scripts_ directory.


## Credits

This repository is based on a repository [https://github.com/nheidloff/serverless-web-application-ibm-cloud](https://github.com/nheidloff/serverless-web-application-ibm-cloud).   It has been heavily modified for our educational use case.

Check out Neil's blogs and screenshots for more details:

* [Developing Serverless Web Applications on the IBM Cloud](http://heidloff.net/article/serverless-web-applications-ibm)
* [Hosting Resources for Web Applications on the IBM Cloud](http://heidloff.net/article/hosting-static-web-resources-ibm-cloud)
* [Authentication of Users in Serverless Applications](http://heidloff.net/article/user-authentication-serverless-openwhisk)
* [User Authorization in Serverless Web Applications](http://heidloff.net/article/user-authorization-serverless-web-applications-openwhisk)
* [Screenshots](documentation/serverless-web-apps.pdf)
* Short [video](documentation/serverless-web-app.mp4) of the Angular application
