var http = require('http');
var koa = require('koa');
var app = koa();

//  Sets the PORT to the env variable or default
var PORT = process.env.PORT ? process.env.PORT : 3001;

//  Simple Use function for return
app.use(function *() {
  this.type = 'application/json';
  this.body = {
    message : 'I like to eat cheese',
    port: PORT
  };
});

//  Creates a simple server
http.createServer(app.callback()).listen(PORT);