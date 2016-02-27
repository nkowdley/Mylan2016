//db.mylan.insert({"id":"user1","accel_freq":[],"accel_amp":[],"hr_avg":[],"gyro_freq":[],"gyro_amp":[],"pedometer_num":[],"skin_temp":[]});
var mongoose = require('mongoose');
//var app = express();
var db=mongoose.connection;

var schema = new mongoose.Schema({
  //data
  id: String,
  accel_freq:[],
  accel_amp:[],
  hr_avg:[],
  gyro_freq:[],
  gyro_amp:[],
  pedometer_num:[],
  skin_temp:[],
  //thresholds
  hr_thresh:Number,
  skin_thresh:Number,
  accel_thresh:Number,
  pedometer_thresh:Number,
  //alert bits
  hr_alert:Number,
  skin_alert:Number,
  pedometer_alert:Number,
  accel_alert:Number
});

var something=mongoose.model('Patient', schema);

module.exports = mongoose.model('Patient', schema);
