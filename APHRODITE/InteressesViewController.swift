//
//  InteressesViewController.swift
//  APHRODITE
//
//  Created by Vincent van der Palen on 08-06-16.
//  Copyright © 2016 Vincent van der Palen. All rights reserved.
//

import UIKit

class InteressesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    @IBOutlet weak var ProgressLabel: UILabel!
    @IBOutlet weak var ProgressBar: KDCircularProgress!

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadJsonData()
        tableView.delegate = self
        tableView.dataSource = self
        
        let backItem = UIBarButtonItem()
        backItem.title = "Overzicht"
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
        ProgressBar.clockwise = false
        ProgressBar.glowAmount = 0.2
        self.title = "Gekoppeld met Lisa"

        
        //Hides backbutton
        self.navigationItem.setHidesBackButton(true, animated:true)

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tableView.reloadData()
        if appDelegate.index <= appDelegate.questionsArray.count {
            let newAngleValue = newAngle()
            
            
            ProgressBar.animateToAngle(newAngleValue, duration: 0.5, completion: nil)
            ProgressLabel.text = (String(Int(updateLabel())) + "%")
            
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (appDelegate.questionsArray.count > 0) //checks local if there were any recent visited clubs
        {
            return appDelegate.questionsArray.count //make tableviews for each visited club
        }
        return 0;
    }
    
    
      func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        let currentRow = indexPath.row
        let currentQuestion = self.appDelegate.questionsArray[currentRow]
        // Configure the cell...
        cell.textLabel?.text = currentQuestion.title
        if(currentQuestion.answer == "")
        {
            cell.imageView?.image = UIImage(named: "QUESTION_MARK")
        }
        else
        {
            cell.imageView?.image = UIImage(named: "CHECK")

        }
        return cell
    }
    
    
    func parseJsonData(jsonObject: AnyObject)
    {
        if let jsonData = jsonObject as? NSArray
        {
            
            for item in jsonData
            {
                let question = InteresseVragen(
                    Subject: item.objectForKey("onderwerp") as! String,
                    Title: item.objectForKey("titel") as! String,
                    Answer: item.objectForKey("antwoord") as! String
                )
                appDelegate.questionsArray.append(question)
                
            }
        }
    


    }
    
    func loadJsonData()
    {
        let url = NSURL(string: "http://athena.fhict.nl/users/i316770/Interesses.json")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request){(data, response, error) -> Void in
            do
            {
                if let jsonObject: AnyObject = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                {
                    self.parseJsonData(jsonObject)
                }
            }
            catch
            {
                print("Error parsing JSON data!")
            }
        }
        dataTask.resume();
        
    }
    
    func newAngle() -> Double {
        return (360 * Double(Double(appDelegate.index) / Double(appDelegate.questionsArray.count)))
    }
    func updateLabel() -> Double {
        return (100 * Double(Double(appDelegate.index) / Double(appDelegate.questionsArray.count)))
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "CellClick")
        {

        var selectedRow = self.tableView.indexPathForSelectedRow
        var selectedTitle = self.appDelegate.questionsArray[selectedRow!.row]
        var controller = segue.destinationViewController as! CardsViewController
        controller.singleQuestion = selectedTitle
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
