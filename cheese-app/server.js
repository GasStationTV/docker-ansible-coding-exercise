var http = require('http');
var koa = require('koa');
var app = koa();

var PORT = process.env.PORT ? process.env.PORT : 3001;
if (process.env.PORT) {
  console.log('Using Port', process.env.PORT);
}

if (process.env.CONTAINER_NAME) {
  console.log('ContainerName: ', process.env.CONTAINER_NAME);
}

app.use(function *(){
  this.type = 'application/json';
  this.body = {
    message : 'Hello World',
    port: PORT
  };
  if (process.env.CONTAINER_NAME) {
    this.body.container = process.env.CONTAINER_NAME;
  }
});

app.on('error', function () {
  console.log('Error occurred');
});

http.createServer(app.callback()).listen(PORT);