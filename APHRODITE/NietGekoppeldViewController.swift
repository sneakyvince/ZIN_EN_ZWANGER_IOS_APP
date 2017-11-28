//
//  NietGekoppeldViewController.swift
//  APHRODITE
//
//  Created by Vincent van der Palen on 08-06-16.
//  Copyright © 2016 Vincent van der Palen. All rights reserved.
//

import UIKit


class NietGekoppeldViewController: UIViewController {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(animated: Bool) {
        if(appDelegate.gekoppeld == true)
        {
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("InteresseVragen")
            self.showViewController(vc as! InteressesViewController, sender: vc)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Koppelen"
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
