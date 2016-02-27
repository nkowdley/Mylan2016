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

var accel_x : Double = 0.0
var accel_y : Double = 0.0
var accel_z : Double = 0.0
var gyro_x : Double = 0.0
var gyro_y : Double = 0.0
var gyro_z : Double = 0.0
var heartRate : Double = 0.0
var stepRate : Double = 0.0
var skinTemp : Double = 0.0

let seconds = 4.0
let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))


class ViewController: UIViewController, MSBClientManagerDelegate {
    var client: MSBClient?
    weak var heart:MSBSensorHeartRateData?
    @IBOutlet weak var accLab: UILabel!


    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        MSBClientManager.sharedManager().delegate = self
        print(MSBClientManager.sharedManager().attachedClients().first)
        if let client = MSBClientManager.sharedManager().attachedClients().first as? MSBClient {
            self.client = client
            MSBClientManager.sharedManager().connectClient(self.client)
       
            
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
           //while(true){
            try client.sensorManager.startAccelerometerUpdatesToQueue(nil, withHandler: { (accelerometerData: MSBSensorAccelerometerData!, error: NSError!) in
                print(NSString(format: "Accel Data: X=%+lf Y=%+lf Z=%+lf", accel_x, accel_y, accel_z))
            })
            delay(0.3)
            try client.sensorManager.stopAccelerometerUpdatesErrorRef()

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
                /*let url = NSURL(string: "http://172.26.161.202:9000/update")
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
           // }
        }
        catch{
            print("accel no work")
        }
        print("boobies")
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
}

