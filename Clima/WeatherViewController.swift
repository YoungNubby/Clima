//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON



class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate { //we get an error, without having a function that uses one of these delegates
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    /***Get your own App ID at https://openweathermap.org/appid ****/
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        //tapping into privacy requests^^^
        locationManager.startUpdatingLocation()
        //actually searching for location^^^
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    func getWeatherData(url: String, parameters: [String: String]) {
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Success! Got the weather data!")
                
                let weatherJSON : JSON = JSON(response.result.value!)
                //print(weatherJSON)
                //this prints to the console, good for building and testing, but "we dont need to print our weather data every time"
                //that will slow you down
                
                self.updateWeatherData(json: weatherJSON)
                //when calling functions inside of other functions (closures), it can get tricky
                //when you are inside an enclosure, we see keyword in, lets you know you are in an enclosure
                //MUST specify self, this will have the compiler search within the current class
                //our current class is stated at the top and named:
                //class WeatherViewController: UIViewController, CLLocationManagerDelegate { }
                
                
                
            }
            else {
                print("Error \(response.result.error)")
                self.cityLabel.text = "Connection Issues"
            }
        }
        
    }
    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json : JSON) {
         //this method is used to parse and seperate out the info that we wish to populate our labels
        
        if let tempResult = json["main"]["temp"].double {
        //this states, we want temperature, its going to equal a value inside this json, temperature is a value associated with the key temp inside a dictionary called main, of the JSON
        //we use double for the large integer
        //we make it an if statement to avoid crashing, "optional binding"
            
            print(json["main"]["temp"].double)
        
        weatherDataModel.temperature = Int((tempResult * 1.8) - 459.67)
        //temp is returned in kelvin, minus 237.15 to turn it into celsius
        
        weatherDataModel.city = json["name"].stringValue
        //stringValue turns json data into string data we can use to populate city
        
        weatherDataModel.condition = json["weather"][0]["id"].intValue
        
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
        updateUIWithWeatherData()
            
        }
        else { //if we do not see a main and a temp in a json, there is a bug, i.e. "Weather Unavailable", our code is now safer and more robust
            cityLabel.text = "Weather Unavailable"
        }
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherData() {
        
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)°"
        //same as "\(data.data)"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            
            
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    
    //Write the didFailWithError method here: incase you cannot retrieve location
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city: String) {
        print(city)
        let params : [String : String] = ["q" : city, "appid" : APP_ID]
        
        getWeatherData(url: WEATHER_URL, parameters: params)
        
    }

    
    //Write the PrepareForSegue Method here
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            
            let destinationVC = segue.destination as! ChangeCityViewController 
            
            destinationVC.delegate = self
            
        }
    }
    
    
    
    
}


