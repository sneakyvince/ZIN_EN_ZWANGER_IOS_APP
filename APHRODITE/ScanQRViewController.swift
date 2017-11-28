//
//  ScanQRViewController.swift
//  APHRODITE
//
//  Created by Fhict on 09/06/16.
//  Copyright © 2016 Vincent van der Palen. All rights reserved.
//

import UIKit

class ScanQRViewController: UIViewController {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    
    @IBOutlet weak var QRView: UIImageView!
    var qrcodeImage: CIImage!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if qrcodeImage == nil {
            let id = "2"
            let data = id.dataUsingEncoding(NSUTF8StringEncoding)
            
            let filter = CIFilter(name: "CIQRCodeGenerator")
            
            filter!.setValue(data, forKey: "inputMessage")
            filter!.setValue("Q", forKey: "inputCorrectionLevel")
            
            qrcodeImage = filter!.outputImage
            
            QRView.image = UIImage(CIImage: qrcodeImage)
            
        }


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    
        if(segue.identifier == "Gekoppeld")
        {
            appDelegate.gekoppeld = true
        }
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
