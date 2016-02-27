var express = require('express');
var router = express.Router();
var mongoose = require('mongoose');
var db=mongoose.connection;
/* GET Test page. */
router.get('/', function(req, res, next) {
  res.render('../tests/updatetest.html');
});
module.exports = router;
