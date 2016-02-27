var express = require('express');
var router = express.Router();

/* GET home page. I don't think this does anything */
router.get('/', function(req, res, next) {
  res.send("yolo");
  res.sendfile('../client/app/index.html');
});

module.exports = router;
