//
//  AppUtility.swift
//  VideoRecorderApp
//
//  Created by Aamir Shehzad on 11/10/2022.
//

import Foundation
import UIKit
import Photos

//com.Metadata.EasyExifEditor

class AppUtility {
    
    /*
     // Method: hexColor
     // Description: Use method to get color from hex string
     // Param: Hex color string without #
     */
    public class func hexColor(hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    /*
     // Method: validateEmail
     // Description: Use method to validate email format
     // Param: email
     */
    public class func validateEmail(with email: String?) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
    
    /*
     // Method: validatePassword
     // Description: Use method to validate password field length
     // Param: password
     */
    public class func validatePassword(password: String) -> Bool {
        if password.count < 8 {
            return false
        }
        return true
    }
    
    /*
     // Method: Is Textfield empty
     // Description: Check Textfield is empty or not
     */
    public class func isTextFieldEmpty(textFieldText:String) -> Bool {
        if textFieldText == "" {
            return true
        } else {
            return false
        }
    }
    
    /*
     // Method: showMessage
     // Description: Show message alert to user
     // params: title, message, controller
     */
    public class func showMessage(title:String, message:String, controller:UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            print("User click Approve button")
        }))
        
        controller.present(alert, animated: true, completion: {
            print("completion block")
        })
        
    }
    
    /*
     // Method: unableViewUserInteraction
     // Description: To unable/disable view
     // params: isEnable, controller
     */
    public class func unableViewUserInteraction(isEnable:Bool, controller:UIViewController) {
        controller.view.resignFirstResponder()
        controller.view.isUserInteractionEnabled = isEnable
    }
    
    /*
     // Method: hexStringToUIColor
     // Description: To get UIColor against Hex string
     // params: hex
     */
    public class func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    /*
     // Method: removeProfileDataFromCache
     // Description: Remove Profile Data From Cache
     // params: no Params
     */
    public class func removeProfileDataFromCache() {
        let prefs = UserDefaults.standard
        prefs.removeObject(forKey:"profileData")
    }
    
    /*
     // Method: getComponentsFromDate
     // Description: Touple to get day month and year from date with formate "yyyy-MM-dd'T'HH:mm:ss"
     // params: strDate: String
     // Return: Touple with 3 values (year, month, day)
     */
    public class func getComponentsFromDate(strDate:String) -> (year:String,month:String,day:String) {
        let dateString = strDate//"2018-12-24 18:00:00 UTC"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        guard let date = formatter.date(from: dateString) else {
            return (year:"",month:"",day:"")
        }
        formatter.dateFormat = "yyyy"
        let year = formatter.string(from: date)
        formatter.dateFormat = "MMM"
        let month = formatter.string(from: date)
        formatter.dateFormat = "dd"
        let day = formatter.string(from: date)
        print(year, month, day) // 2018 12 24
        
        return (year:year, month:month,day:day)
    }
    
    /*
     // Method: getComponentsFromServerDate
     // Description: Touple to get day month and year from date with formate "yyyy-MM-dd'T'HH:mm:ss"
     // params: strDate: String
     // Return: Touple with 3 values (year, month, day)
     */
    public class func getComponentsFromServerDate(strDate:String) -> (year:String,month:String,day:String) {
        let dateString = strDate//"2018-12-24 18:00:00 UTC"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let date = formatter.date(from: dateString) else {
            return (year:"",month:"",day:"")
        }
        formatter.dateFormat = "yyyy"
        let year = formatter.string(from: date)
        formatter.dateFormat = "MMM"
        let month = formatter.string(from: date)
        formatter.dateFormat = "dd"
        let day = formatter.string(from: date)
        print(year, month, day) // 2018 12 24
        
        return (year:year, month:month,day:day)
    }
    
    /*
     // Method: getHeightAccoringToText
     // Description: get text view height from text
     // params: strText: String, desiredWidth:Float
     // Return: Double (Height)
     */
    public class func getHeightAccoringToText(strText:String,desiredWidth:CGFloat) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: desiredWidth, height: .greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.text = strText
        label.sizeToFit()
        return label.frame.height
    }
    

    /*
     // Method: getDateFromIntervel
     // Description: get date from time intervel integer
     // params: timeInterval:Int64
     // Return: return Date
     */
    public class func getDateFromIntervel(timeInterval:Double) -> Date {
        print("timeInterval = \(timeInterval)")
        
        let myDate = Date(timeIntervalSince1970: timeInterval)
        // let myDate = NSDate(timeIntervalSince1970: epocTime)
        print("Converted Time \(myDate)")
        
        //        let date = NSDate(timeIntervalSince1970: timeInterval)
        //
        let dayTimePeriodFormatter = DateFormatter()
        
        dayTimePeriodFormatter.dateFormat = "HH:mm a E, d MMM yyyy"
        dayTimePeriodFormatter.timeZone = TimeZone(abbreviation: "EST")
        dayTimePeriodFormatter.timeZone = TimeZone.current
        let dateString = dayTimePeriodFormatter.string(from: myDate)
        
        print( " _ts value is \(timeInterval)")
        print( " _ts value is \(dateString)")
        // print("getDateStringFromUTC = \(Double("1645253459127.0")?.getDateStringFromUTC() ?? "")")
        return myDate as Date
        
    }
    
    
    /*
     // Method: getDateStringWithFormate
     // Description: get date string with suggested formate
     // params: formate:String?,date:Date
     // Return: return Date string
     */
    public class func getDateStringWithFormate(formate:String,date:Date) -> String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = formate //?? "MMM dd,yyyy"
        dateFormatterPrint.timeZone = TimeZone(abbreviation: "EST")
        dateFormatterPrint.timeZone = TimeZone.current
        let dateString = dateFormatterPrint.string(from: date)
        print(dateString)
        return dateString
    }
    
    /*
     // Method: getColosArray
     // Description: get coller array
     // Return: return colors string array
     */
    public class func getColosArray() -> [String] {
        return ["E5E5E5", "FE990D", "081733", "EB0000", "731377", "CB291D", "2E6A1F"]
    }
    
    /*
     // Method: getDefaultTags
     // Description: get default tags array
     // Return: tag array in the form of TagStruct
     */
    public class func getDefaultTags() -> [TagStruct] {
            return [TagStruct(title: "Makes", color: "731377"), TagStruct(title: "Misses", color: "CB291D"), TagStruct(title: "TOs", color: "CB291D"), TagStruct(title: "Label4", color: "CB291D"), TagStruct(title: "Label5", color: "CB291D"), TagStruct(title: "Label6", color: "CB291D"), TagStruct(title: "Label7", color: "CB291D"), TagStruct(title: "TOs", color: "2E6A1F")]
        }
    
    /*
     // Method: saveImageToDocumentDirectory
     // Description: Method used to save image to document directory
     // Params: image: UIImage, imageName:String
     // Return: UIImage
     */
    public class func saveImageToDocumentDirectory(image: UIImage, imageName:String) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = imageName // name of the image to be saved
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        if let data = image.jpegData(compressionQuality: 1.0),!FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try data.write(to: fileURL)
                print("file saved")
            } catch {
                print("error saving file:", error)
            }
        }
    }
    
    /*
     // Method: getCollerArray
     // Description: Method used to get colors hex strings array
     // Return: [String]
     */
    public class func getCollerArray() -> [String] {
        return ["CB291D", "EE8531", "F8BC40", "2E6A1F", "0400F0", "731377"]
    }
    
    /*
     // Method: saveTagArray
     // Description: save tag array
     // Return: return tag array
     */
    public class func saveTagArray(tagArray:[TagStruct]) {
        do {
            let data = try JSONEncoder().encode(tagArray)
            UserDefaults.standard.set(data, forKey: "TagsArray")
        } catch  {
            print(error)
        }
    }
    
    /*
     // Method: retriveTagArray
     // Description: save tag array
     // Return: return tag array
     */
    public class func retriveTagArray() -> [TagStruct] {
        var folderArray: [TagStruct] = []
        if let data = UserDefaults.standard.data(forKey: "TagsArray") {
            do {
                let arr = try JSONDecoder().decode([TagStruct].self, from: data)
                print(arr)
                folderArray = arr
            } catch {
                print(error)
            }
        }
        return folderArray
    }
    
}

extension Double {
    
    func getDateStringFromUTC() -> String {
        let date = Date(timeIntervalSince1970: self)
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "EST")
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateStyle = .medium
        
        return dateFormatter.string(from: date)
    }
    
}

extension Date {
    
    func timeAgoDisplay() -> String {
        
        let calendar = Calendar.current
        let minuteAgo = calendar.date(byAdding: .minute, value: -1, to: Date())!
        let hourAgo = calendar.date(byAdding: .hour, value: -1, to: Date())!
        let dayAgo = calendar.date(byAdding: .day, value: -1, to: Date())!
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        
        if minuteAgo < self {
            let diff = Calendar.current.dateComponents([.second], from: self, to: Date()).second ?? 0
            return "\(diff) sec ago"
        } else if hourAgo < self {
            let diff = Calendar.current.dateComponents([.minute], from: self, to: Date()).minute ?? 0
            return "\(diff) min ago"
        } else if dayAgo < self {
            let diff = Calendar.current.dateComponents([.hour], from: self, to: Date()).hour ?? 0
            return "\(diff) hrs ago"
        } else if weekAgo < self {
            let diff = Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
            return "\(diff) days ago"
        }
        let diff = Calendar.current.dateComponents([.weekOfYear], from: self, to: Date()).weekOfYear ?? 0
        return "\(diff) weeks ago"
    }
    
}

class Toast {
    
    static func show(message: String, controller: UIViewController) {
        let toastContainer = UIView(frame: CGRect())
        toastContainer.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastContainer.alpha = 0.0
        toastContainer.layer.cornerRadius = 25;
        toastContainer.clipsToBounds  =  true
        
        let toastLabel = UILabel(frame: CGRect())
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font.withSize(12.0)
        toastLabel.text = message
        toastLabel.clipsToBounds  =  true
        toastLabel.numberOfLines = 0
        
        toastContainer.addSubview(toastLabel)
        controller.view.addSubview(toastContainer)
        
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let a1 = NSLayoutConstraint(item: toastLabel, attribute: .leading, relatedBy: .equal, toItem: toastContainer, attribute: .leading, multiplier: 1, constant: 15)
        let a2 = NSLayoutConstraint(item: toastLabel, attribute: .trailing, relatedBy: .equal, toItem: toastContainer, attribute: .trailing, multiplier: 1, constant: -15)
        let a3 = NSLayoutConstraint(item: toastLabel, attribute: .bottom, relatedBy: .equal, toItem: toastContainer, attribute: .bottom, multiplier: 1, constant: -15)
        let a4 = NSLayoutConstraint(item: toastLabel, attribute: .top, relatedBy: .equal, toItem: toastContainer, attribute: .top, multiplier: 1, constant: 15)
        toastContainer.addConstraints([a1, a2, a3, a4])
        
        let c1 = NSLayoutConstraint(item: toastContainer, attribute: .leading, relatedBy: .equal, toItem: controller.view, attribute: .leading, multiplier: 1, constant: 65)
        let c2 = NSLayoutConstraint(item: toastContainer, attribute: .trailing, relatedBy: .equal, toItem: controller.view, attribute: .trailing, multiplier: 1, constant: -65)
        let c3 = NSLayoutConstraint(item: toastContainer, attribute: .bottom, relatedBy: .equal, toItem: controller.view, attribute: .bottom, multiplier: 1, constant: -75)
        controller.view.addConstraints([c1, c2, c3])
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            toastContainer.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseOut, animations: {
                toastContainer.alpha = 0.0
            }, completion: {_ in
                toastContainer.removeFromSuperview()
            })
        })
    }
    
}
 
extension Calendar {
    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let fromDate = startOfDay(for: from)
        let toDate = startOfDay(for: to)
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate)
        
        return numberOfDays.day! + 1 // <1>
    }
    
    func numberOf24DaysBetween(_ from: Date, and to: Date) -> Int {
        let numberOfDays = dateComponents([.day], from: from, to: to)
        
        return numberOfDays.day! + 1
    }
}

struct TagStruct : Codable {
    var title: String
    var color: String
 
}
