//
//  RegisterViewController.swift
//  TickTok User
//
//  Created by Excellent Webworld on 25/10/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit
import CountryPickerView
import DropDown

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var txtPhoneNumber: ThemeTextField!
    @IBOutlet weak var segmentLang: UISegmentedControl!
    @IBOutlet weak var txtEmail: ThemeTextField!
    
    @IBOutlet weak var txtPassword: ThemeTextField!
    
    @IBOutlet weak var txtConfirmPassword: ThemeTextField!
    
    @IBOutlet weak var btnNext: ThemeButton!
    
    @IBOutlet weak var lblFirstStep: UILabel!
    
    @IBOutlet weak var lblSecondStep: UILabel!
    
    @IBOutlet var btnCountryCode: UIButton!
    
    @IBOutlet weak var stackPassword: UIStackView!
    @IBOutlet weak var stackConfirmPassword: UIStackView!
    
    var arrLang: [String] = ["English","Spanish"]
    @IBOutlet weak var btnSelectLanguage: UIButton!
    
    let countryPicker = CountryPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnSelectLanguage.titleLabel?.numberOfLines = 0
        
        txtPhoneNumber.delegate = self
        txtEmail.delegate = self
        txtPassword.delegate = self
        txtConfirmPassword.delegate = self
        self.SetLayout()
        
        if SingletonClass.sharedInstance.isFromSocilaLogin == true
        {
            self.txtEmail.text = SingletonClass.sharedInstance.strSocialEmail
        }
        countryPicker.delegate = self
        btnCountryCode.setTitle("+592", for: .normal)

//        txtPhoneNumber.placeHolderColor = UIColor.red
        // Do any additional setup after loading the view.
        
        if(AppDelegate.current?.isSocialLogin ?? true){
            self.stackPassword.isHidden = true
            self.stackConfirmPassword.isHidden = true
        }else{
            self.stackPassword.isHidden = false
            self.stackConfirmPassword.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        NotificationCenter.default.addObserver(self, selector: #selector(changeLanguage), name: Notification.Name(rawValue: LCLLanguageChangeNotification), object: nil)
        segmentLang.selectedConfiguration(color: .white)
        segmentLang.selectedSegmentIndex = (Localize.currentLanguage() == Languages.English.rawValue) ? 0 : 1
        segmentLang.addTarget(self, action: #selector(indexChanged(_:)), for: .valueChanged)
        self.setLocalization()
    }
    
    @objc func indexChanged(_ sender: UISegmentedControl) {
        if segmentLang.selectedSegmentIndex == 0 {
            Localize.setCurrentLanguage(Languages.English.rawValue)
        } else if segmentLang.selectedSegmentIndex == 1 {
            Localize.setCurrentLanguage(Languages.Spanish.rawValue)
        }
    }
    
    @IBAction func btnSelectLangAction(_ sender: Any) {
        self.SelectLangDropdownSetup()
    }
    
    func SelectLangDropdownSetup() {
        let dropDown = DropDown()
        dropDown.anchorView = self.btnSelectLanguage
        dropDown.dataSource = self.arrLang
        dropDown.show()
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            if(index == 0){
                Localize.setCurrentLanguage(Languages.English.rawValue)
            }else{
                Localize.setCurrentLanguage(Languages.Spanish.rawValue)
            }
            dropDown.hide()
        }
        dropDown.width = self.btnSelectLanguage.frame.width
        self.view.endEditing(true)
    }
    
    @objc func changeLanguage(){
        self.setLocalization()
    }
    
    func setLocalization(){
        txtPhoneNumber.placeholder = "Phone Number".localized
        txtEmail.placeholder = "Email".localized
        txtPassword.placeholder = "Password".localized
        txtConfirmPassword.placeholder = "Confirm Password".localized
        btnNext.setTitle("Next".localized, for: .normal)
        btnSelectLanguage.setTitle("Select Language".localized, for: .normal)
    }
    
    @IBAction func btnCountryCode(_ sender: Any) {
        countryPicker.showPhoneCodeInView = true
        countryPicker.showCountriesList(from: self)
    }
    
    //-------------------------------------------------------------
    //MARK: - Textfield Delegate Methods

    //-------------------------------------------------------------
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (string == " ") {
            return false
        }
        if textField == txtPhoneNumber {
            let resultText: String? = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
            
            if resultText!.count >= 11 {
                return false
            }
            else {
                return true
            }
        } 
        return true
    }
    
    
 
    // MARK: - Navigation
    
    
    @IBAction func btnNext(_ sender: Any) {
        guard (txtPhoneNumber.text?.count != 0) || (txtEmail.text?.count != 0) || (txtPassword.text?.count != 0) || (txtConfirmPassword.text?.count != 0) else {
            UtilityClass.setCustomAlert(title: "Missing".localized, message: "Please fill all details".localized) { (index, str) in
            }
            return
        }
        if (validateAllFields()){
            webserviceForGetOTPCode(email: txtEmail.text!, mobile: "\(txtPhoneNumber.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")")
        }
    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //-------------------------------------------------------------
    // MARK: - validation Email Methods
    //-------------------------------------------------------------
    
    func validateAllFields() -> Bool
    {
     
        let isEmailAddressValid = isValidEmailAddress(emailID: txtEmail.text!)
        
        if (txtPhoneNumber.text?.count == 0)
        {

            UtilityClass.setCustomAlert(title: "Missing".localized, message: "Please enter phone number".localized) { (index, title) in
            }

            return false
        }
//        else if ((txtPhoneNumber.text?.count)! < 10)
//        {
//
//            UtilityClass.setCustomAlert(title: "Missing", message: "Please enter a valid phone number".localized) { (index, title) in
//            }
//
//            return false
//        }
        else if (txtEmail.text?.count == 0)
        {
            UtilityClass.setCustomAlert(title: "Missing".localized, message: "Please enter email".localized) { (index, title) in
            }

            return false
        }else if (!isEmailAddressValid){
            UtilityClass.setCustomAlert(title: "Missing".localized, message: "Please enter a valid email".localized) { (index, title) in
            }
            return false
        }
        
        if((AppDelegate.current?.isSocialLogin ?? false) == false){
            if (txtPassword.text?.count == 0){
                UtilityClass.setCustomAlert(title: "Missing".localized, message: "Please enter password".localized) { (index, title) in
                }
                return false
            }else if ((txtPassword.text?.hasPrefix(" ") == true) || (txtPassword.text?.hasSuffix(" ") == true)){
                UtilityClass.setCustomAlert(title: "Error", message: "Your password can’t start or end with a blank space".localized) { (index, title) in
                }
                return false
            }else if ((txtPassword.text?.count)! < 6){
                UtilityClass.setCustomAlert(title: "Required".localized, message: "Password must contain at least 8 characters".localized) { (index, title) in
                }
                return false
            }else if (txtConfirmPassword.text?.count == 0){
                UtilityClass.setCustomAlert(title: "Missing".localized, message: "Please confirm the password".localized) { (index, title) in
                }
                return false
            }else if ((txtConfirmPassword.text?.count)! < 6){
                UtilityClass.setCustomAlert(title: "Required".localized, message: "Password must contain at least 8 characters".localized) { (index, title) in
                }
                return false
            }else if ((txtConfirmPassword.text?.hasPrefix(" ") == true) || (txtConfirmPassword.text?.hasSuffix(" ") == true)){
                UtilityClass.setCustomAlert(title: "Required".localized, message: "Confirm password can’t start or end with a blank space".localized) { (index, title) in
                }
                return false
            }else if (txtPassword.text != txtConfirmPassword.text){
                UtilityClass.setCustomAlert(title: "Missing".localized, message: "Password and confirm password does not match".localized) { (index, title) in
                }
                return false
            }
        }
        return true
    }
    
    
    func isValidEmailAddress(emailID: String) -> Bool
    {
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z)-9.-]+\\.[A-Za-z]{2,3}"
        
        do{
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailID as NSString
            let results = regex.matches(in: emailID, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
        }
        catch _ as NSError
        {
            returnValue = false
        }
        
        return returnValue
    }
    
    func setCustomAlert(title: String, message: String) {
        AJAlertController.initialization().showAlertWithOkButton(aStrTitle: title, aStrMessage: message) { (index,title) in
        }
     
    }
    
    func webserviceForGetOTPCode(email: String, mobile: String) {
        
//      Param : MobileNo,Email

        var param = [String:AnyObject]()
        param["MobileNo"] = mobile as AnyObject
        param["Email"] = email as AnyObject
        param["CountryCode"] = btnCountryCode.titleLabel?.text as AnyObject

        webserviceForOTPRegister(param as AnyObject) { (result, status) in
            if (status) {
                print(result)
                let datas = (result as! [String:AnyObject])
                
                UtilityClass.showAlertWithCompletion("OTP Code", message: (datas[GetResponseMessageKey()] as! String).firstCharacterUpperCase(), vc: self, completionHandler: { ACTION in
                    if let otp = datas["otp"] as? String {
                        SingletonClass.sharedInstance.otpCode = otp
                    }else if let otp = datas["otp"] as? Int {
                        SingletonClass.sharedInstance.otpCode = "\(otp)"
                    }
                    let registrationContainerVC = self.navigationController?.viewControllers.last as! RegistrationContainerViewController
                    registrationContainerVC.scrollObject.setContentOffset(CGPoint(x: self.view.frame.size.width, y: 0), animated: true)
                })
                
//                if let SelectedLanguage = UserDefaults.standard.value(forKey: "i18n_language") as? String {
//                    if SelectedLanguage == "en" {
//                        UtilityClass.showAlertWithCompletion("OTP Code", message: (datas[GetResponseMessageKey()] as! String).firstCharacterUpperCase(), vc: self, completionHandler: { ACTION in
//                            if let otp = datas["otp"] as? String {
//                                SingletonClass.sharedInstance.otpCode = otp
//                            }else if let otp = datas["otp"] as? Int {
//                                SingletonClass.sharedInstance.otpCode = "\(otp)"
//                            }
//                            let registrationContainerVC = self.navigationController?.viewControllers.last as! RegistrationContainerViewController
//                            registrationContainerVC.scrollObject.setContentOffset(CGPoint(x: self.view.frame.size.width, y: 0), animated: true)
//                        })
//                    }else //if SelectedLanguage == "sw"
//                    {
//                        UtilityClass.showAlertWithCompletion("OTP Code".localized, message: datas["swahili_message"] as! String, vc: self, completionHandler: { ACTION in
//                            if let otp = datas["otp"] as? String {
//                                SingletonClass.sharedInstance.otpCode = otp
//                            }
//                            else if let otp = datas["otp"] as? Int {
//                                SingletonClass.sharedInstance.otpCode = "\(otp)"
//                            }
//                            let registrationContainerVC = self.navigationController?.viewControllers.last as! RegistrationContainerViewController
//                            registrationContainerVC.scrollObject.setContentOffset(CGPoint(x: self.view.frame.size.width, y: 0), animated: true)
//                        })
//                    }
//                }
            }else {
                 print(result)
                if let res = result as? String {
                    UtilityClass.setCustomAlert(title: "Error", message: res) { (index, title) in
                    }
                }else if let resDict = result as? NSDictionary {
                    UtilityClass.setCustomAlert(title: "Error", message: resDict.object(forKey:  GetResponseMessageKey()) as! String) { (index, title) in
                    }
                }else if let resAry = result as? NSArray {
                    UtilityClass.setCustomAlert(title: "Error", message: (resAry.object(at: 0) as! NSDictionary).object(forKey: GetResponseMessageKey()) as! String) { (index, title) in
                    }
                }
            }
        }
    }
}

//-------------------------------------------------------------
// MARK: - Custom Methods
//-------------------------------------------------------------

extension RegisterViewController {
    func SetLayout() {
        self.lblFirstStep.layer.cornerRadius = 12.5
        self.lblSecondStep.layer.cornerRadius = 12.5
        self.lblFirstStep.layer.masksToBounds = true
        self.lblSecondStep.layer.masksToBounds = true
    }
}

extension String {
    func firstCharacterUpperCase() -> String! {
        guard !isEmpty else { return nil }
        let lowerCasedString = self.lowercased()
        return lowerCasedString.replacingCharacters(in: lowerCasedString.startIndex...lowerCasedString.startIndex, with: String(lowerCasedString[lowerCasedString.startIndex]).uppercased())
    }
}



extension RegisterViewController: CountryPickerViewDelegate {
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        btnCountryCode.setTitle(country.phoneCode, for: .normal)
    }
    
//    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
//        btnCountryCode.setTitle(country.phoneCode, for: .normal)
//    }
}

extension RegisterViewController: CountryPickerViewDataSource {
    func navigationTitle(in countryPickerView: CountryPickerView) -> String? {
        return "Select a Country"
    }
        
    func searchBarPosition(in countryPickerView: CountryPickerView) -> SearchBarPosition {
        return .tableViewHeader
    }
    
    func showPhoneCodeInList(in countryPickerView: CountryPickerView) -> Bool {
        return true
    }
    
    func showCountryCodeInList(in countryPickerView: CountryPickerView) -> Bool {
       return false
    }
}
