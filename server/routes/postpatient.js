var express = require('express');
var router = express.Router();
var mongoose = require('mongoose');
var db=mongoose.connection;
var oldpatient= require('../models/patient.js');
/* GET home page. */
/* Post home page. */
router.post('/', function(req, res, next) {

  //var user = new oldpatient({
  var user={
    id: req.body.id,
    accel_freq:[],
    accel_amp:[],
    hr_avg:[],
    gyro_freq:[],
    gyro_amp:[],
    pedometer_num:[],
    skin_temp:[],
    hr_thresh:req.body.hr_thresh,
    skin_thresh:req.body.skin_thresh,
    accel_thresh:req.body.accel_thresh,
    pedometer_thresh:req.body.pedometer_thresh,
    hr_alert:req.body.hr_alert,
    skin_alert:req.body.skin_alert,
    pedometer_alert:req.body.pedometer_alert,
    accel_alert:req.body.accel_alert
  };//);
  //save the user to mongo
  // user.save(function (err, user) {
  //   if (err) return console.error(err);
  // });

 db.collection('mylan').insert(user)


res.end();
});

module.exports = router;
