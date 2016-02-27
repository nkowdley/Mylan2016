var express = require('express');
var router = express.Router();
var mongoose = require('mongoose');
var db=mongoose.connection;
/* GET home page. */
router.get('/', function(req, res, next) {
//dump all jobs
  var query = {'id':req.query['id']};
  db.collection('mylan').findOne(query, function(err, info){
    if (err)
    {
      console.log("Error:(err)");
      return next(err);
    }
    res.send(info);
  });
});
module.exports = router;
