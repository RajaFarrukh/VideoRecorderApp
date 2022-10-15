//
//  CreateTagViewController.swift
//  VideoRecorderApp
//
//  Created by Aamir Shehzad on 14/10/2022.
//

import UIKit

class CreateTagViewController: UIViewController {

    var colorsArray:[String] = []
    var selectedColor:String = ""
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var colorsCollectionView: UICollectionView!
    @IBOutlet weak var selectedColorView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
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
     // Description: Method uset to setup page initially
     */
    func setupView() {
        
        let nibName = UINib(nibName: "ColorsCollectionViewCell", bundle:nil)
        self.colorsCollectionView.register(nibName, forCellWithReuseIdentifier: "ColorCell")
        
        self.colorsArray = AppUtility.getColosArray()
        
        self.colorsCollectionView.delegate = self
        self.colorsCollectionView.dataSource = self
        self.colorsCollectionView.reloadData()
    }
    
    
    // MARK: - IBAction Methods
    
    /*
     // Method: onBtnBack
     // Description: IBAction for back button
     */
    @IBAction func onBtnBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    /*
     // Method: onBtnPreview
     // Description: IBAction for preview button
     */
    @IBAction func onBtnPreview(_ sender: Any) {
        
        if self.titleTextField.text == "" {
            return
        }
        
        if self.selectedColor == "" {
            return
        }
        
        self.titleLabel.text = self.titleTextField.text?.capitalized
        self.selectedColorView.backgroundColor = AppUtility.hexColor(hex: self.selectedColor)
    }
    
    /*
     // Method: onBtnDone
     // Description: IBAction for back button
     */
    @IBAction func onBtnDone(_ sender: Any) {
       
        if self.titleTextField.text == "" {
            return
        }
        
        if self.selectedColor == "" {
            return
        }
        
        let titleString = self.titleTextField.text ?? ""
        let colorString = self.selectedColor ?? ""
        
        let objTagStruct = TagStruct(title: titleString, color: colorString)
        
        var tagArray = AppUtility.retriveTagArray()
        tagArray.append(objTagStruct)
        AppUtility.saveTagArray(tagArray: tagArray)
        
        navigationController?.popViewController(animated: true)
        
    }
    
}


// MARK: - UICollectionView Delegate and Database Methods

extension CreateTagViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.colorsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:ColorsCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath as IndexPath) as! ColorsCollectionViewCell
        
        let colorHexString = self.colorsArray[indexPath.row]
        cell.colorView.backgroundColor = AppUtility.hexColor(hex: colorHexString)
        
        if self.selectedColor == colorHexString {
            cell.checkedImageView.isHidden = false
        } else {
            cell.checkedImageView.isHidden = true
        }
        
        cell.backgroundColor = UIColor.clear
        return cell
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 74, height: 74)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
     
        self.selectedColor = self.colorsArray[indexPath.row]
        
        self.colorsCollectionView.delegate = self
        self.colorsCollectionView.dataSource = self
        self.colorsCollectionView.reloadData()
        
    }
    
}
