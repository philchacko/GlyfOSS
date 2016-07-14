//
//  PostNewViewController.swift
//  Glyf
//
//  Created by Philip Chacko on 8/27/15.
//  Copyright (c) 2015 Phil Chacko. All rights reserved.
//

import UIKit
import Foundation
import GoogleMaps
import Mixpanel

protocol addrPickProtocol {
    func updatePostAddress(selected: SelectedPlace?)
}

class PostNewViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate {

    var delegate: addrPickProtocol?
    var addrString: String?
    var placesClient: GMSPlacesClient?
    var resultsGMS: [GMSAutocompletePrediction]?
    var placeNames: [String]?
    
    @IBOutlet weak var addrInputField: UITextField!
    @IBOutlet weak var resultsTable: UITableView!
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().statusBarHidden = true
        
        placeNames = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        placesClient = GMSPlacesClient.sharedClient()
        
        addrInputField.delegate = self
        addrInputField.text = addrString
        addrInputField.addTarget(self, action: "reloadAutoComplete", forControlEvents: UIControlEvents.EditingChanged)
        
        reloadAutoComplete()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadAutoComplete() {
        if addrInputField.text != nil {
        self.placesClient?.autocompleteQuery(addrInputField.text!, bounds: nil, filter: nil, callback: {
            (results, error: NSError?) -> Void in
            if let error = error {
                print("Autocomplete error \(error)")
            }
            else {
                //print(results)
                self.placeNames = nil
                self.resultsGMS = results as? [GMSAutocompletePrediction]
                //print(self.resultsGMS)
                self.resultsTable.reloadData()
            }
        })
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.resultsGMS != nil {
            return resultsGMS!.count
        }
        else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: AutocompleteResultsCell = tableView.dequeueReusableCellWithIdentifier("autoCompleteCell") as! AutocompleteResultsCell
        
        //let regularFontMed = UIFont.systemFontOfSize(UIFont.labelFontSize())
        //let boldFontMed = UIFont.boldSystemFontOfSize(UIFont.labelFontSize())
        //let regularFontSmall = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        //let boldFontSmall = UIFont.boldSystemFontOfSize(UIFont.smallSystemFontSize())
        
        if indexPath.row < self.resultsGMS?.count {
            
            cell.labelPlaceTitle.text = ""
            cell.labelPlaceDetail.text = ""
            
            let resultAsString = resultsGMS![indexPath.row].attributedFullText.mutableCopy().mutableString
            var commaParse = resultAsString.componentsSeparatedByString(", ")
            cell.labelPlaceTitle.text = commaParse[0]
            if placeNames == nil {
                placeNames = [commaParse[0] ]
            }
            else {
                placeNames?.append(commaParse[0] )
            }
            
            if commaParse.count > 1 {
                let detailString1 = commaParse[1] 
                
                if commaParse.count > 2 {
                    let detailString2 = commaParse[2] 
                    cell.labelPlaceDetail.text = "\(detailString1), \(detailString2)"
                }
                else {
                    cell.labelPlaceDetail.text = detailString1
                }
            }
            
            /*let boldedResultDetail = resultsGMS![indexPath.row].attributedFullText.mutableCopy() as! NSMutableAttributedString
            let placeComponents = boldedResultDetail.mutableString.componentsSeparatedByString(", ")
            let firstCommaRange = boldedResultDetail.mutableString.rangeOfString(", ")
            if firstCommaRange.location != NSNotFound {
                let max = NSMaxRange(firstCommaRange)
                let boldedResultDetailExTitle = boldedResultDetail.mutableString.substringFromIndex(max)
                println("ExTitle_shouldhavenospace_\(boldedResultDetailExTitle)")
            }
            /*if let firstComma = boldedResultDetail.mutableString.rangeOfString(", ") {
                println("First comma: \(firstComma)")
                let subString = boldedResultDetail.mutableString[firstComma.endIndex..<boldedResultDetail.mutableString.endIndex]
                
            }*/
            
            /*if placeComponents[0] as? String != nil {
                cell.labelPlaceTitle.text = placeComponents[0] as? String
            }*/
            //let secondComma = boldedResultDetail.mutableString.rangeOfString(", ", options: NSStringCompareOptions., range: <#NSRange#>)
            boldedResultDetail.enumerateAttribute(kGMSAutocompleteMatchAttribute, inRange: NSMakeRange(0, boldedResultDetail.length), options: nil) { (value, range: NSRange, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                let font = (value == nil) ? regularFontSmall : boldFontSmall
                boldedResultDetail.addAttribute(NSFontAttributeName, value: font, range: range)
            }
            
            cell.labelPlaceDetail.attributedText = boldedResultDetail*/
        }
        else {
            cell.labelPlaceTitle.text = "ERROR"
            cell.labelPlaceDetail.text = "ERROR"
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        Mixpanel.sharedInstance().track("DidSelectAutocompleteRow")
        
        let selected = SelectedPlace()
        selected.fullAddress = resultsGMS![indexPath.row].attributedFullText.string
        selected.googlePlaceID = resultsGMS![indexPath.row].placeID
        selected.types = resultsGMS![indexPath.row].types as! [String]
        selected.placename = placeNames![indexPath.row]
        placesClient?.lookUpPlaceID(selected.googlePlaceID, callback: { (placeResultGMS, error) -> Void in
            if error != nil {
                print(error)
                self.delegate?.updatePostAddress(selected)
            }
            else {
                selected.coordinates = placeResultGMS!.coordinate
                self.delegate?.updatePostAddress(selected)
            }
        })
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func btnCancelTapped(sender: AnyObject) {
        delegate?.updatePostAddress(nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

class SelectedPlace {
    
    var fullAddress: String = ""
    var googlePlaceID: String = ""
    var types: NSArray?
    var placename: String = ""
    var coordinates: CLLocationCoordinate2D?
    
}
