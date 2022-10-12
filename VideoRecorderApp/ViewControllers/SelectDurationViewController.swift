//
//  SelectDurationViewController.swift
//  VideoRecorderApp
//
//  Created by Aamir Shehzad on 12/10/2022.
//

import UIKit

class SelectDurationViewController: UIViewController {

    @IBOutlet weak var startPickerView: UIPickerView!
    @IBOutlet weak var stopPickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupView()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Other Methods
    
    /*
     // Method: setupView
     // Description: Method used to initial setup for controller
     */
    func setupView() {
        
        self.startPickerView.dataSource = self
        self.startPickerView.delegate = self
        self.startPickerView.reloadAllComponents()
        
        self.stopPickerView.dataSource = self
        self.stopPickerView.delegate = self
        self.stopPickerView.reloadAllComponents()
        
    }
    
    // MARK: - IBAction Methods
    
    /*
     // Method: onBtnBack
     // Description: IBAction for back button
     */
    @IBAction func onBtnBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    

}

extension SelectDurationViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    //MARK: - Pickerview method
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 10
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(format: "%d", row)
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
         
    }
    
}
