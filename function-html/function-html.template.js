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
      <script>document.write('<base href="' + document.location.href.substr(0, document.location.href.indexOf("/web")+4) + '" />');</script>
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <link rel="icon" type="image/x-icon" href="favicon.ico">
    </head>
    <body>
      <div class="container">
      <app-root></app-root>
      </div>
    <script type="text/javascript" src="xxx-replace-me-xxx/runtime-es2015.js" type="module"></script>
    <script type="text/javascript" src="xxx-replace-me-xxx/runtime-es5.js" nomodule defer></script>
    <script type="text/javascript" src="xxx-replace-me-xxx/polyfills-es5.js" nomodule defer></script>
    <script type="text/javascript" src="xxx-replace-me-xxx/polyfills-es2015.js" type="module"></script>
    <script type="text/javascript" src="xxx-replace-me-xxx/styles-es2015.js" type="module"></script>
    <script type="text/javascript" src="xxx-replace-me-xxx/styles-es5.js" nomodule defer></script>
    <script type="text/javascript" src="xxx-replace-me-xxx/scripts.js" defer></script>
    <script type="text/javascript" src="xxx-replace-me-xxx/vendor-es2015.js" type="module"></script>
    <script type="text/javascript" src="xxx-replace-me-xxx/vendor-es5.js" nomodule defer></script>
    <script type="text/javascript" src="xxx-replace-me-xxx/main-es2015.js" type="module"></script>
    <script type="text/javascript" src="xxx-replace-me-xxx/main-es5.js" nomodule defer></script></body>
    </html>
    
    
    `}
  }
