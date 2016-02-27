//
//  ViewController.swift
//  mylan
//
//  Created by swaroop akkineni on 2/26/16.
//  Copyright © 2016 swaroop akkineni. All rights reserved.
//
//qimport <MicrosoftBandKit_iOS/MicrosoftBandKit_iOS.h>
import UIKit
import Foundation
import Accelerate
import Darwin


var accel_x : Double = 0.0
var accel_y : Double = 0.0
var accel_z : Double = 0.0
var gyro_x : Double = 0.0
var gyro_y : Double = 0.0
var gyro_z : Double = 0.0
var heartRate : Double = 0.0
var stepRate : Double = 0.0
var i : Int = 0
//var skinTemp : Double = 0.0
var client_bool: Bool = false

let seconds = 4.0
let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))

var accel_array = [Double]()
var gyro_array = [Double]()
var zero_data = [Double]()
var act_accel_array = [Double]()
var act_gyro_array = [Double]()
var act_zero_data = [Double]()
MSBClient
var temp_array = 32.8
var heart_Data = 87.0



//currentTime = NSDate.timeIntervalSinceReferenceDate()
//let elapsedTime = currentTime - startTime


class ViewController: UIViewController, MSBClientManagerDelegate {
    var client: MSBClient?
    weak var heart:MSBSensorHeartRateData?
    @IBOutlet weak var accLab: UILabel!
    var startTime = NSDate.timeIntervalSinceReferenceDate()
    var currentTime = NSDate.timeIntervalSinceReferenceDate()
    var elapsedTime : Double = 0.0

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLoad() {
        super.viewDidLoad()
         startTime = NSDate.timeIntervalSinceReferenceDate()
        // Do any additional setup after loading the view, typically from a nib.
        
        MSBClientManager.sharedManager().delegate = self
        print(MSBClientManager.sharedManager().attachedClients().first)
            if let client = MSBClientManager.sharedManager().attachedClients().first as? MSBClient {
                self.client = client
             
                
               ////////////////////////////////////
                
                
                
                
                
                
                //while(client_bool == false){
                    MSBClientManager.sharedManager().connectClient(self.client)
                //}
                //print("connection works back")
                //}
            } else {
                // self.output("Failed! No Bands attached.")
                print("No luck bromigo")
            }
    }



    func clientManager(clientManager: MSBClientManager!, clientDidConnect client: MSBClient!) {
        //self.output("Band connected.")
        print("band connected")
        print(client)
        do{
            try client.sensorManager.startAccelerometerUpdatesToQueue (nil, withHandler:
            { (accelerometerData: MSBSensorAccelerometerData!, error: NSError!) in print(NSString(format: "Accel Data: X=%+lf Y=%+lf Z=%+lf", accelerometerData.x, accelerometerData.y, accelerometerData.z) )
                    let magn = sqrt( accelerometerData.x * accelerometerData.x + accelerometerData.y * accelerometerData.y + accelerometerData.z * accelerometerData.z)
                    accel_array.append(magn)
                    zero_data.append(0.0)
                    self.currentTime = NSDate.timeIntervalSinceReferenceDate()
                    let diff_time = self.currentTime - self.startTime
                    print(diff_time)
                    if(diff_time >= 20){
                        act_accel_array = accel_array
                        act_gyro_array = gyro_array
                        act_zero_data = zero_data

                        let radix2 = FFTRadix(kFFTRadix2)
                        let round_ed : Int = 512
                        print("Rounded", round_ed)
                        let bobby = vDSP_Length(round_ed)
                        //let bob = UInt(bobby)
                        print("fftsetup",bobby)
                        let fft_Setup = vDSP_create_fftsetupD( 9, radix2)
                        print("accel" ,  act_accel_array.count )
                        print("imag" , zero_data.count )
                        for index in act_zero_data.count...round_ed{
                            accel_array.append(0.0)
                            zero_data.append(0.0)
                        }

                        var array = DSPDoubleSplitComplex(realp: &act_accel_array, imagp: &act_zero_data)
                        vDSP_fft_zripD(fft_Setup, &array, 1, 9, FFTDirection(FFT_FORWARD));
                        var array_2 = DSPDoubleSplitComplex(realp: &act_gyro_array, imagp: &act_zero_data)
                        vDSP_fft_zripD(fft_Setup, &array_2, 1, 9, FFTDirection(FFT_FORWARD));

                        var output_accel_array = [Double]()
                        var output_gyro_array = [Double]()

                        for index in 1...(act_accel_array.count / 2) {
                            output_accel_array.append(abs(act_accel_array[index]))
                            print("accel", act_accel_array[index])
                        }
                        for index in 1...(act_gyro_array.count / 2) {
                            output_gyro_array.append(abs(act_gyro_array[index]))
                            print("gyro", act_gyro_array[index])

                        }
                        print("Skin_temp", temp_array)
                        print("heart_temp", heart_Data)

                        print("sending data")
                        self.currentTime = NSDate.timeIntervalSinceReferenceDate()
                        self.startTime = NSDate.timeIntervalSinceReferenceDate()
                        let url = NSURL(string: "http://172.26.161.202:9000/update")
                        let request = NSMutableURLRequest(URL: url!)
                        request.HTTPMethod = "POST"
                        var post_String = "id=user1&accel_amp= " + String(output_accel_array)
                            post_String += "&gyro_amp= " + String(output_gyro_array)
                            post_String += "&hr_avg= " + String(heart_Data)
                            post_String += "&skin_temp= " + String(temp_array)

                        request.HTTPBody = post_String.dataUsingEncoding(NSUTF8StringEncoding)
                        
                        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
                            guard error == nil && data != nil else {                                                          // check for fundamental networking error
                                print("error = \(error)")
                                return
                            }
                            
                            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {           // check for http errors
                                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                                print("response = \(response)")
                            }
                            
                            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                            print("responseString = \(request.HTTPBody)")
                        }
                        task.resume()
                        print("/        Sent Data                          ////////////////////////////////////////////")
                        accel_array.removeAll()

                    }
                }
                
            )
        }
        catch {
            print("accel no work")
        }
        
        do{
            try client.sensorManager.startGyroscopeUpdatesToQueue (nil, withHandler:
                { (gyro_data: MSBSensorGyroscopeData!, error: NSError!) in print(NSString(format: "Gyro Data: X=%+lf Y=%+lf Z=%+lf", gyro_data.x, gyro_data.y, gyro_data.z) )
                    let magn = sqrt( gyro_data.x * gyro_data.x + gyro_data.y * gyro_data.y + gyro_data.z * gyro_data.z)
                        gyro_array.append(magn)
                }
                
            )
        }
        catch {
            print("gyro no work")
        }
        do{
            try client.sensorManager.startSkinTempUpdatesToQueue(nil, withHandler: { (skinTempData: MSBSensorSkinTemperatureData!, error: NSError!) in
                print(NSString(format: "Skin Temp: %+lf", skinTempData.temperature))
                //temp_array.append(32.0)
                if(skinTempData.temperature > 20){
                   temp_array=(skinTempData.temperature)
                }
                //skin_data=(skinTempData.temperature)
            }
        
            )
        }
        catch {
            print("temp no work")
        }
        let consent = self.client!.sensorManager.heartRateUserConsent()
        switch (consent){
        default:
            do {
                try client.sensorManager.startHeartRateUpdatesToQueue(nil, withHandler: { (heart_rate: MSBSensorHeartRateData!, error: NSError!) in
                    print(NSString(format: "HeartRate Data: Heart_Rate=%+lf", heart_rate.heartRate))
                    //heart_Data.append( (Double(heart_rate.heartRate)))
                    print("heart data", heart_rate.heartRate)
                    if(heart_rate.heartRate > 70){
                        heart_Data = Double(heart_rate.heartRate)
                    }
                    }
                )
                
            }
            catch{
                print(error)
            }
        }
               /* do {
                    try client.sensorManager.startGyroscopeUpdatesToQueue (nil, withHandler:
                        { (gyro_data: MSBSensorGyroscopeData!, error: NSError!) in print(NSString(format: "Gyro Data: X=%+lf Y=%+lf Z=%+lf", gyro_data.x, gyro_data.y, gyro_data.z) )
                            /////////////////////////
                            do {
                                try client.sensorManager.startSkinTempUpdatesToQueue(nil, withHandler: { (skinTempData: MSBSensorSkinTemperatureData!, error: NSError!) in
                                    print(NSString(format: "Skin Temp: %+lf", skinTempData.temperature))
                                    /////////////////////////
                                    
                                    do {
                                        try client.sensorManager.startHeartRateUpdatesToQueue(nil, withHandler: { (heart_rate: MSBSensorHeartRateData!, error: NSError!) in
                                            print(NSString(format: "HeartRate Data: Heart_Rate=%+lf", heart_rate.heartRate))
                                            }
                                        )
                                        
                                    }
                                    catch{
                                        print(error)
                                    }
                                    
                                    ///////////////////// 
                                    
                                    }
                                )
                                
                            }
                            catch{
                                print("stop temp")
                            }
                            
                            /////////////////////
                        }
                    )

                }
                catch{
                    print("stop gyro")
                }*/
        


        print("dummy")

        //try client.sensorManager.stopAccelerometerUpdatesErrorRef()

         //MSBClientManager.sharedManager().cancelClientConnection(self.client)
    }
   
    func clientManager(clientManager: MSBClientManager!, clientDidDisconnect client: MSBClient!) {
        //self.output(")Band disconnected.")
        print("band disconnected")

    }
    
    func clientManager(clientManager: MSBClientManager!, client: MSBClient!, didFailToConnectWithError error: NSError!) {
        //self.output("Failed to connect to Band.")
        //self.output(error.description)
        print("Failed to connect to Band.")
        
    }
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
}
/*do{
//while(true){
//if(accel_x == 0){
try client.sensorManager.startAccelerometerUpdatesToQueue(nil, withHandler: { (accelerometerData: MSBSensorAccelerometerData!, error: NSError!) in
print(NSString(format: "Accel Data: X=%+lf Y=%+lf Z=%+lf", accel_x, accel_y, accel_z) )
})

try client.sensorManager.stopAccelerometerUpdatesErrorRef()

// delay(1.0){}

try client.sensorManager.startGyroscopeUpdatesToQueue(nil, withHandler: { (accelerometerData: MSBSensorGyroscopeData!, error: NSError!) in
print(NSString(format: "Gyro Data: X=%+lf Y=%+lf Z=%+lf", gyro_x, gyro_y, gyro_z))
})
try client.sensorManager.stopGyroscopeUpdatesErrorRef()

try client.sensorManager.startHeartRateUpdatesToQueue(nil, withHandler: { (accelerometerData: MSBSensorHeartRateData!, error: NSError!) in
print(NSString(format: "HeartRate Data: Heart_Rate=%+lf", heartRate))
})
try client.sensorManager.stopHeartRateUpdatesErrorRef()

try client.sensorManager.startPedometerUpdatesToQueue(nil, withHandler: { (accelerometerData: MSBSensorPedometerData!, error: NSError!) in
print(NSString(format: "Pedometer Data: Step_rate=%+lf", stepRate))
})
try client.sensorManager.stopPedometerUpdatesErrorRef()

try client.sensorManager.startSkinTempUpdatesToQueue(nil, withHandler: { (accelerometerData: MSBSensorSkinTemperatureData!, error: NSError!) in
print(NSString(format: "Skin Temp: Step_rate=%+lf", skinTemp))
})
try client.sensorManager.stopSkinTempUpdatesErrorRef()

print("/////////////////////////////////////////////")
}
catch{
print("accel no work")
}*/

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////


/*
let url = NSURL(string: "http://172.26.161.202:9000/update")
let request = NSMutableURLRequest(URL: url!)

//let request = NSMutableURLRequest(URL: NSURL(string: "https://www.thisismylink.com/postName.php")!)
request.HTTPMethod = "POST"
var post_String = "id=user1&accel_freq= " + String(accel_x)
print(post_String)
request.HTTPBody = post_String.dataUsingEncoding(NSUTF8StringEncoding)

let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
guard error == nil && data != nil else {                                                          // check for fundamental networking error
print("error = \(error)")
return
}

if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {           // check for http errors
print("statusCode should be 200, but is \(httpStatus.statusCode)")
print("response = \(response)")
}

let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
print("responseString = \(request.HTTPBody)")
}
task.resume()
print("/////////////////////////////////////////////")*/




