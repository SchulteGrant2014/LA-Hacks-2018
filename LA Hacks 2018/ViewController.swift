//
//  ViewController.swift
//  LA Hacks 2018
//
//  Created by Grant Schulte on 3/31/18.
//  Copyright © 2018 Consonants. All rights reserved.
//

import UIKit
import Charts


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // -------------------- Member Variables ---------------------
    
    var receipts: [Receipt] = []
    
    // chart stuff
    var pieChartView: PieChartView!
    var lineChartView: LineChartView!
    
    
    // -------------------- Default functions --------------------
    
    func userData() {
        // call class method
        var userDefaults = UserDefaults.standard
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.        
        var testReceipt: Receipt
        if let img = UIImage(named: "tj4") {
            testReceipt = Receipt(image: img)
        } else {
            print("I didn't run :(")
        }
        
        //charts
        //categories of nutrients
        let nutrients = ["Protein", "Lipids", "Carbs", "Fiber", "Sugar"]
        //daily intake pie chart
        let piePercentage = [1.2, 0.8, 0.5, 1.72, 0.88]
        
        //ratio of intake vs average
        let linePercentage = [1.2, 0.8, 0.43, 1.72, 0.88]
        
        //base line: average intake for each nutrient
        let baseline = [1.0, 1.0, 1.0, 1.0, 1.0]
        
        //set position and bounds
        pieChartView = PieChartView(frame: CGRect(x: 70, y: 90, width: 225, height: 225))
        self.view.addSubview(pieChartView!)
        lineChartView = LineChartView(frame: CGRect(x: 52.5, y: 310, width: 270, height: 270))
        self.view.addSubview(lineChartView!)
        
        //call methods that put data into charts
        setPieChart(dataPoints: nutrients, values: piePercentage)
        setLineChart(dataPoints: nutrients, values: linePercentage, baseValues: baseline)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //chart funcs
    func setPieChart(dataPoints: [String], values: [Double]) {
        
        var pieChartEntries: [ChartDataEntry] = []
        
        //store values in an array of entries
        for i in 0..<dataPoints.count {
            let dataEntry1 = PieChartDataEntry(value: values[i], label: dataPoints[i])
            pieChartEntries.append(dataEntry1)
        }
        
        let pieChartDataSet = PieChartDataSet(values: pieChartEntries, label: nil)
        
        //set font and font size
        pieChartDataSet.valueFont = UIFont(name: "Verdana", size: 10.0)!
        pieChartDataSet.valueColors = ([NSUIColor.black])
        
        //add data to view
        let pieChartData = PieChartData()
        pieChartData.addDataSet(pieChartDataSet)
        self.pieChartView.data = pieChartData
        
        //visual formatting for pie chart
        pieChartDataSet.colors = ChartColorTemplates.joyful()
        pieChartView.chartDescription?.text = ""
        pieChartView.legend.enabled = false
    }
    
    func setLineChart(dataPoints: [String], values: [Double], baseValues: [Double])
    {
        var lineChartEntries: [ChartDataEntry] = []
        var baseLineEntries: [ChartDataEntry] = []
        
        //store values in an array of entries
        for i in 0..<dataPoints.count {
            let dataEntry2 = ChartDataEntry(x: Double(i), y: values[i])
            lineChartEntries.append(dataEntry2)
        }
        
        //store base values in an array of entries
        for i in 0..<dataPoints.count {
            let dataEntry3 = ChartDataEntry(x: Double(i), y: baseValues[i])
            baseLineEntries.append(dataEntry3)
        }
        
        //make lines for real data and base data
        let line1 = LineChartDataSet(values: lineChartEntries, label: nil)
        let baseLine = LineChartDataSet(values: baseLineEntries, label: nil)
        
        //visual formatting for lines
        line1.valueFont = UIFont(name: "Verdana", size: 8.0)!
        let lineColor = UIColor(red: 12/255, green: 122/255, blue: 30/255, alpha: 1)
        line1.colors = [lineColor]
        baseLine.colors = ([NSUIColor.black])
        baseLine.drawCirclesEnabled = false
        baseLine.drawValuesEnabled = false
        
        //add data to view
        let lineChartData = LineChartData()//dataSet: line1)
        lineChartData.addDataSet(line1)
        lineChartData.addDataSet(baseLine)
        lineChartView.data = lineChartData
        
        //visual formatting for graph axes
        lineChartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.leftAxis.axisMinimum = 0.0
        lineChartView.leftAxis.drawLabelsEnabled = false
        lineChartView.leftAxis.drawGridLinesEnabled = false
        lineChartView.rightAxis.drawGridLinesEnabled = false
        lineChartView.rightAxis.drawLabelsEnabled = false
        lineChartView.legend.enabled = false
        lineChartView.chartDescription?.text = ""
        lineChartView.isUserInteractionEnabled = false
        //lineChartView.fitScreen()
        lineChartView.xAxis.labelFont = UIFont(name: "Verdana", size: 9.0)!
        lineChartView.xAxis.granularity = 1
        lineChartView.setExtraOffsets(left: 20, top: 0, right: 20, bottom: 0)
        
    }
    
    
    // -------------------- UI Element Function Connections --------------------
    
    @IBAction func unwindToViewController(_ sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? AddImageViewController {
            if let image = sourceViewController.ImageDisplay.image {
                if receipts.count == 5 {
                    receipts.removeFirst(1)
                    receipts.append(Receipt(image: image))
                } else {receipts.append(Receipt(image: image))}
            }
        }
    }
    
}


