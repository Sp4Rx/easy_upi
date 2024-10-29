import Flutter
import UIKit

public class EasyUpiPlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "easy_upi", binaryMessenger: registrar.messenger())
        let instance = EasyUpiPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "getAllUpiApps":
            getAllUpiApps(result: result)
        case "startTransaction":
            guard let args = call.arguments as? [String: Any],
                  let upiUri = args["upiUri"] as? String,
                  let appScheme = args["app"] as? String else {
                result(FlutterError(code: "invalid_arguments", message: "Missing required arguments", details: nil))
                return
            }
            startTransaction(upiUri: upiUri, appScheme: appScheme, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - Get All UPI Apps
    private func getAllUpiApps(result: @escaping FlutterResult) {
        
        var upiApps: [String] = []
        var installedAppsInfo: [[String: Any]] = []
        
        // Load content of Info.plist into resourceFileDictionary dictionary
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
           let resourceFileDictionary = NSDictionary(contentsOfFile: path) {
            // Retrieve the value from plist
            upiApps = resourceFileDictionary.object(forKey: "LSApplicationQueriesSchemes") as? [String] ?? []
        }
        
        let app = UIApplication.shared
        let group = DispatchGroup() // To handle asynchronous fetching

        for installedApp in upiApps {
            let appScheme = "\(installedApp)://app"
            if app.canOpenURL(URL(string: appScheme)!) {
                // If the app is installed, fetch the app icon
                group.enter() // Enter the dispatch group
                fetchAppIcon(for: installedApp) { iconData in
                    let appInfo: [String: Any] = [
                        "name": installedApp,
                        "packageName": appScheme,
                        "icon": iconData ?? Data() // Return empty data if nil
                    ]
                    installedAppsInfo.append(appInfo)
                    group.leave() // Leave the dispatch group
                }
            }
        }
        
        // Notify when all icon fetching is completed
        group.notify(queue: .main) {
            result(installedAppsInfo)
        }
    }
    
    // Function to fetch app icon from iTunes API
    private func fetchAppIcon(for appName: String, completion: @escaping (Data?) -> Void) {
        let urlString = "https://itunes.apple.com/search?term=\(appName)&entity=software&country=IN"
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let results = json?["results"] as? [[String: Any]],
                   let iconURLString = results.first?["artworkUrl100"] as? String,
                   let iconURL = URL(string: iconURLString) {
                    // Fetch the icon image data
                    self.downloadImageData(from: iconURL) { imageData in
                        completion(imageData)
                    }
                } else {
                    completion(nil)
                }
            } catch {
                completion(nil)
            }
        }.resume()
    }
    
    // Function to download image data from URL
    private func downloadImageData(from url: URL, completion: @escaping (Data?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            completion(data)
        }.resume()
    }
    
    // MARK: - Start UPI Transaction
    private func startTransaction(upiUri: String, appScheme: String, result: @escaping FlutterResult) {
        guard let url = URL(string: upiUri) else {
            result(FlutterError(code: "invalid_uri", message: "Invalid UPI URI", details: nil))
            return
        }
        
        if let appUrl = URL(string: appScheme), UIApplication.shared.canOpenURL(appUrl) {
            UIApplication.shared.open(url, options: [:]) { success in
                if success {
                    result("Transaction initiated")
                } else {
                    result(FlutterError(code: "failed_to_launch", message: "Failed to open UPI app", details: nil))
                }
            }
        } else {
            result(FlutterError(code: "app_not_installed", message: "Requested UPI app not installed", details: nil))
        }
    }
}
