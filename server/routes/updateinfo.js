var express = require('express');
var router = express.Router();
var mongoose = require('mongoose');
var db=mongoose.connection;
/* GET home page. */
router.post('/', function(req, res, next) {
  //console.log(req);
  var query = {'id':req.body.id};
  db.collection('mylan').findOneAndUpdate(query,{$push: {accel_freq: req.body.accel_freq, accel_amp: req.body.accel_amp, hr_avg:req.body.hr_avg, gyro_freq:req.body.gyro_freq, gyro_amp:req.body.gyro_amp, pedometer_num:req.body.pedometer_num, skin_temp:req.body.skin_temp }}, {upsert:true}, function(err, doc){
    if (err)
    {
      console.log("error"+err);
    }
  });
  var hr_thresh=0;
  var pedometer_thresh=0;
  var skin_thresh=0;
res.end();
});
module.exports = router;
