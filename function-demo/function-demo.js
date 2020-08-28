// we copy the index.html in angular/dist/index.html
// and add the xxx-replace-me-xxx/ string which will 
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
      <script>document.write('<base href="' + document.location.href.substr(0, document.location.href.indexOf("/demo")+5) + '" />');</script>
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <link rel="icon" type="image/x-icon" href="favicon.ico">
      <script
			  src="https://code.jquery.com/jquery-3.5.1.min.js"
			  integrity="sha256-9/aliU8dGd2tb6OSsuzixeV4y/faTqgFtohetphbbj0="
        crossorigin="anonymous"></script>
      <link rel="stylesheet" type="text/css" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
      <script type="text/javascript" src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    </head>
    <body>
      <div class="container">
        <ul>
        <li><a href="https://eu-gb.functions.appdomain.cloud/api/v1/web/31a5de2e-fcbf-4a96-ab2c-188783dd8537/serverlessweb-50-pkg-public/angular">Angular Demo</a></li>
        <li><a href="https://eu-gb.functions.appdomain.cloud/api/v1/web/31a5de2e-fcbf-4a96-ab2c-188783dd8537/serverlessweb-50-pkg-public/reactwebapp">React Demo</a></li>
        <li><a href="https://eu-gb.functions.appdomain.cloud/api/v1/web/31a5de2e-fcbf-4a96-ab2c-188783dd8537/serverlessweb-50-pkg-public/laravelwebapp">Laravel Demo</a></li>
        <li><a href="https://eu-gb.functions.appdomain.cloud/api/v1/web/31a5de2e-fcbf-4a96-ab2c-188783dd8537/serverlessweb-50-pkg-public/flaskwebapp">Flask Demo</a></li>
        <li><a href="https://eu-gb.functions.appdomain.cloud/api/v1/web/31a5de2e-fcbf-4a96-ab2c-188783dd8537/serverlessweb-50-pkg-public/djangowebapp">Django Demo</a></li>
        </ul>
      </div>
    </html>
    
    
    `}
  }
