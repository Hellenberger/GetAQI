//
//  ContentView.swift
//  Get AQI Watch App
//
//  Created by Howard Ellenberger on 1/22/23.
//

import SwiftUI

struct ContentView: View {
    

    @State private var city = ""
    @State private var state = ""
    @State private var airQuality = ""
    
    
    var body: some View {
        
        VStack {
            TextField("Enter City", text: $city)
            TextField("Enter State(optional)", text: $state)
            Button(action: {
                
                let headers = [
                    "content-type": "application/json",
                    "X-RapidAPI-Key": "ac3507942emsh0d654ca5c05fc3ap16a5d0jsn89e7a4e5e2f8",
                    //"X-RapidAPI-Host": "https://air-quality-by-api-ninjas.p.rapidapi.com"
                ]
                
                
                var city = "city="+"\(city)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                let state = "state="+"\(state)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                
                if !state.isEmpty {
                    city += "%26&" + state
                }
                
                let request = NSMutableURLRequest(url: NSURL(string: "https://air-quality-by-api-ninjas.p.rapidapi.com/v1/airquality?"+city)! as URL,
                                                  cachePolicy: .useProtocolCachePolicy,
                                                  timeoutInterval: 10.0)
                request.httpMethod = "GET"
                request.allHTTPHeaderFields = headers
                print(request)
                
                let task = URLSession.shared.dataTask(with: request as URLRequest) {(data, response, error) in
                    guard let data = data else { return }
                    let jsonString = String(data: data, encoding: .utf8)!
                    do {
                        
                        let json = try JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!) as! [String: Any]
                        print(json)
                        guard let overall_aqi = json["overall_aqi"] as? Int
                        else {
                            DispatchQueue.main.async {
                            self.airQuality = "Can't Find City"
                        }
                        return
                            
                        }
                        
                        DispatchQueue.main.async {
                            self.airQuality = "\(overall_aqi)"
                        }
                        
                        if let httpResponse = response as? HTTPURLResponse {
                            if httpResponse.statusCode != 200 {
                                print(error!)
                                
                            }
                        }
                    } catch {
                        print(error)
                    }
                }
                task.resume()
                
            }, label: {
                Text("Get AQI")
                    .foregroundColor(.yellow)
                    .font(.title2)
                
            })
            
            if !airQuality.isEmpty {
                TextField("", text: $airQuality)
                    //.fixedSize()
                    .font(.title3)
                    //.lineLimit(nil)
                    .padding()
                    .foregroundColor(Color.white)
                    .minimumScaleFactor(0.75)
                    .fixedSize(horizontal: true, vertical: false)
 
                    .background(Color.black)
                    .multilineTextAlignment(.center)
                
            }
        }
    }
}


struct AirQuality: Codable {
    let value: String
    let airQuality: String
}

struct AirQualityData: Codable {
    let overall_aqi: String
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
