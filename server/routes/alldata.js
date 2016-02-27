var express = require('express');
var router = express.Router();
var mongoose = require('mongoose');
var db=mongoose.connection;
/* GET home page. */
router.get('/', function(req, res, next) {
//dump all jobs
  db.collection('mylan').find().toArray(function(err, result){
    if (err)
    {
      console.log("Error:(err)");
      return next(err);
    }
    var all_user_data={"data":result};
    res.send(all_user_data);
  });
});
module.exports = router;
