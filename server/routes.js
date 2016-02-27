/**
 * Main application routes
 */
var express = require('express');
'use strict';

import errors from './components/errors';
import path from 'path';

export default function(app) {
  // Insert routes below
  app.use(function(req, res, next) {
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
    next();
  });
  app.use(express.static('file'));
  app.use('/api/things', require('./api/thing'));
  app.use('/', require('./routes/index.js'));
  app.use('/alldata', require('./routes/alldata.js'));
  app.use('/update', require('./routes/updateinfo.js'));
  app.use('/getdata', require('./routes/getuserdata.js'));
  app.use('/createpatient', require('./routes/postpatient.js'));
  app.use('/static', express.static('file'));
  //test pages
  app.use('/update_test', require('./routes/updatetest.js'));
  app.use('/get_test', require('./routes/gettest.js'));
  app.use('/create_test', require('./routes/createtest.js'));
  // All undefined asset or api routes should return a 404
  app.route('/:url(api|auth|components|app|bower_components|assets)/*')
   .get(errors[404]);

  // All other routes should redirect to the index.html
  app.route('/*')
    .get((req, res) => {
      res.sendFile(path.resolve(app.get('appPath') + '/index.html'));
    });
}
