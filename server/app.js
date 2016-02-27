/**
 * Main application file
 */

'use strict';

import express from 'express';
import mongoose from 'mongoose';
mongoose.Promise = require('bluebird');
import config from './config/environment';
import http from 'http';
var fs = require('fs');
var https = require('https');
// Connect to MongoDB
mongoose.connect('mongodb://localhost/mylan', function(err) {
  if(err) {
    console.log('MONGO CONNECTION ERROR', err);
  } else {
    console.log('MONGO CONNECTION SUCCESSFUL');
  }
});

var options = {
  key: fs.readFileSync('file.pem'),
  cert: fs.readFileSync('file.crt')
};
// Populate databases with sample data
if (config.seedDB) { require('./config/seed'); }

// Setup server
var app = express();
//var server = https.createServer(options, app);
var server=http.createServer(app);
var socketio = require('socket.io')(server, {
  serveClient: config.env !== 'production',
  path: '/socket.io-client'
});
require('./config/socketio')(socketio);
require('./config/express')(app);
require('./routes')(app);
// Start server
function startServer() {
  app.angularFullstack = server.listen(config.port, config.ip, function() {
    console.log('Express server listening on %d, in %s mode', config.port, app.get('env'));
  });
}

setImmediate(startServer);

// Expose app
exports = module.exports = app;
