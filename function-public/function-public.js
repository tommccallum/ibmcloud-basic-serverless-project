// we copy the index.html in angular/dist/index.html
// and add the https://s3.eu-gb.cloud-object-storage.appdomain.cloud/sweb-62-bkt-70fdf8f2-3b76-4e58-a77c-b97ffde57d91-djangowebapp/ string which will 
// be replaced with the final url.
// To stop issues with CORS, always have the right MIME type e.g. type="text/javascript" in any imported scripts from the storage object.
// Use <script> line that edits the document base url is there to stop the internal angular links from going back to root.
// Do not begin any other route with /web otherwise this will not work
// 
function main() {
        
    return { 
      
      body: `
    
    <!doctype html>
    <html lang="en">
    <head>
      <meta charset="utf-8">
      <title>OpenwhiskAngular</title>
      <script>document.write('<base href="' + document.location.href.substr(0, document.location.href.indexOf("/djangowebapp")+"xxx-api-name-xxx".length) + '" />');</script>
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <link rel="icon" type="image/x-icon" href="favicon.ico">
    </head>
    <body>
      <div class="container">
      <app-root></app-root>
      </div>
    <script type="text/javascript" src="https://s3.eu-gb.cloud-object-storage.appdomain.cloud/sweb-62-bkt-70fdf8f2-3b76-4e58-a77c-b97ffde57d91-djangowebapp/runtime-es2015.js" type="module"></script>
    <script type="text/javascript" src="https://s3.eu-gb.cloud-object-storage.appdomain.cloud/sweb-62-bkt-70fdf8f2-3b76-4e58-a77c-b97ffde57d91-djangowebapp/runtime-es5.js" nomodule defer></script>
    <script type="text/javascript" src="https://s3.eu-gb.cloud-object-storage.appdomain.cloud/sweb-62-bkt-70fdf8f2-3b76-4e58-a77c-b97ffde57d91-djangowebapp/polyfills-es5.js" nomodule defer></script>
    <script type="text/javascript" src="https://s3.eu-gb.cloud-object-storage.appdomain.cloud/sweb-62-bkt-70fdf8f2-3b76-4e58-a77c-b97ffde57d91-djangowebapp/polyfills-es2015.js" type="module"></script>
    <script type="text/javascript" src="https://s3.eu-gb.cloud-object-storage.appdomain.cloud/sweb-62-bkt-70fdf8f2-3b76-4e58-a77c-b97ffde57d91-djangowebapp/styles-es2015.js" type="module"></script>
    <script type="text/javascript" src="https://s3.eu-gb.cloud-object-storage.appdomain.cloud/sweb-62-bkt-70fdf8f2-3b76-4e58-a77c-b97ffde57d91-djangowebapp/styles-es5.js" nomodule defer></script>
    <script type="text/javascript" src="https://s3.eu-gb.cloud-object-storage.appdomain.cloud/sweb-62-bkt-70fdf8f2-3b76-4e58-a77c-b97ffde57d91-djangowebapp/scripts.js" defer></script>
    <script type="text/javascript" src="https://s3.eu-gb.cloud-object-storage.appdomain.cloud/sweb-62-bkt-70fdf8f2-3b76-4e58-a77c-b97ffde57d91-djangowebapp/vendor-es2015.js" type="module"></script>
    <script type="text/javascript" src="https://s3.eu-gb.cloud-object-storage.appdomain.cloud/sweb-62-bkt-70fdf8f2-3b76-4e58-a77c-b97ffde57d91-djangowebapp/vendor-es5.js" nomodule defer></script>
    <script type="text/javascript" src="https://s3.eu-gb.cloud-object-storage.appdomain.cloud/sweb-62-bkt-70fdf8f2-3b76-4e58-a77c-b97ffde57d91-djangowebapp/main-es2015.js" type="module"></script>
    <script type="text/javascript" src="https://s3.eu-gb.cloud-object-storage.appdomain.cloud/sweb-62-bkt-70fdf8f2-3b76-4e58-a77c-b97ffde57d91-djangowebapp/main-es5.js" nomodule defer></script></body>
    </html>
    
    
    `}
  }
