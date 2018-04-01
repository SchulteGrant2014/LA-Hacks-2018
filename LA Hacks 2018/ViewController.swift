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
    var idealRelativeNutrientPerc: [String:Double] = [ "Protein":11.34594, "Fats":13.570634, "Carbohydrates":61.179088, "Sugars":6.896552, "Dietary Fiber":7.007786 ]
    // Nutrients = ["Protein","Fats","Carbohydrates","Sugars","Dietary Fiber"]
    
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
        if let img = UIImage(named: "tj1") {
            testReceipt = Receipt(image: img)
        } else {
            //print("I didn't run :(")
        }
        
        //charts
        //categories of nutrients
        let nutrients = ["Protein", "Lipids", "Carbs", "Fiber", "Sugar"]
        //daily intake pie chart
        let piePercentage = [1.2, 0.8, 0.5, 1.72, 0.88]
        
        //ratio of intake vs average
        let linePercentage = [1.2, 0.8, 0.43, 1.72, 0.88]
        
        //previous ratio of intake vs average
        let prevPercentage = [0.8, 1.32, 1.13, 0.68, 0.94]
        
        //base line: average intake for each nutrient
        let baseline = [1.0, 1.0, 1.0, 1.0, 1.0]
        
        //set position and bounds
        pieChartView = PieChartView(frame: CGRect(x: 70, y: 90, width: 225, height: 225))
        self.view.addSubview(pieChartView!)
        lineChartView = LineChartView(frame: CGRect(x: 52.5, y: 350, width: 270, height: 270))
        self.view.addSubview(lineChartView!)
        let colors = [UIColor(red: 51/255, green: 183/255, blue: 148/255, alpha: 1), UIColor(red: 78/255, green: 102/255, blue: 191/255, alpha: 1)]
        
        //call methods that put data into charts
        if receipts.count == 0 {
            setEmptyPieChart()
        }
        else{
            setPieChart(dataPoints: nutrients, values: piePercentage)
            addCurrentLine(values: linePercentage)
        }
        setLineChart(dataPoints: nutrients, prevValues: prevPercentage, baseValues: baseline)
        addLegend(num: receipts.count, color: colors)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setEmptyPieChart()
    {
        var emptyPieChartEntries: [ChartDataEntry] = []
        emptyPieChartEntries.append(PieChartDataEntry(value: 100.0, label: "No Data"))
        
        let emptyPieChartDataSet = PieChartDataSet(values: emptyPieChartEntries, label: nil)
        
        //set font and font size
        emptyPieChartDataSet.valueFont = UIFont(name: "Verdana", size: 10.0)!
        emptyPieChartDataSet.valueColors = ([NSUIColor.black])
        
        //add data to view
        let pieChartData = PieChartData()
        pieChartData.addDataSet(emptyPieChartDataSet)
        self.pieChartView.data = pieChartData
        
        //visual formatting for pie chart
        let gray = UIColor(red: 174/255, green: 174/255, blue: 174/255, alpha: 1)
        emptyPieChartDataSet.colors = ([gray])
        pieChartView.chartDescription?.text = ""
        pieChartView.legend.enabled = false
        
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
    
    func setLineChart(dataPoints: [String], prevValues: [Double], baseValues: [Double])
    {
        var prevChartEntries: [ChartDataEntry] = []
        var baseLineEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry3 = ChartDataEntry(x: Double(i), y: prevValues[i])
            prevChartEntries.append(dataEntry3)
        }
        
        //store base values in an array of entries
        for i in 0..<dataPoints.count {
            let dataEntry4 = ChartDataEntry(x: Double(i), y: baseValues[i])
            baseLineEntries.append(dataEntry4)
        }
        
        //make lines for real data and base data
        let line2 = LineChartDataSet(values: prevChartEntries, label: nil)
        let baseLine = LineChartDataSet(values: baseLineEntries, label: nil)
        
        //visual formatting for lines
        
        line2.valueFont = UIFont(name: "Verdana", size: 8.0)!
        let prevLineColor = UIColor(red: 78/255, green: 102/255, blue: 191/255, alpha: 1)
        line2.colors = [prevLineColor]
        
        baseLine.colors = ([NSUIColor.black])
        baseLine.drawCirclesEnabled = false
        baseLine.drawValuesEnabled = false
        
        //add data to view
        let lineChartData = LineChartData()
        lineChartData.addDataSet(line2)
        lineChartData.addDataSet(baseLine)
        lineChartView.data = lineChartData
        
        //visual formatting for graph axes
        lineChartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.labelFont = UIFont(name: "Verdana", size: 9.0)!
        lineChartView.xAxis.granularity = 1
        lineChartView.setExtraOffsets(left: 20, top: 20, right: 20, bottom: 0)
        
        lineChartView.leftAxis.axisMinimum = 0.0
        lineChartView.leftAxis.drawLabelsEnabled = false
        lineChartView.leftAxis.drawGridLinesEnabled = false
        
        lineChartView.rightAxis.drawGridLinesEnabled = false
        lineChartView.rightAxis.drawLabelsEnabled = false
        
        lineChartView.legend.enabled = false
        lineChartView.chartDescription?.text = ""
        lineChartView.isUserInteractionEnabled = false
    }
    
    func addCurrentLine(values: [Double])
    {
        var lineChartEntries: [ChartDataEntry] = []
        
        //store values in an array of entries
        for i in 0..<values.count {
            let dataEntry2 = ChartDataEntry(x: Double(i), y: values[i])
            lineChartEntries.append(dataEntry2)
        }
        
        let line1 = LineChartDataSet(values: lineChartEntries, label: nil)
        
        //visual formatting for lines
        line1.valueFont = UIFont(name: "Verdana", size: 8.0)!
        let lineColor = UIColor(red: 51/255, green: 183/255, blue: 148/255, alpha: 1)
        line1.colors = [lineColor]
        
        //add data to view
        let lineChartData = LineChartData()//dataSet: line1)
        lineChartData.addDataSet(line1)
        lineChartView.data = lineChartData
    }
    
    
    func addLegend(num: Int, color: [UIColor])
    {
        lineChartView.legend.enabled = true
        lineChartView.legend.xEntrySpace = 60.0
         let secondLegend = LegendEntry.init(label: "Previous", form: .default, formSize: CGFloat.nan, formLineWidth: CGFloat.nan, formLineDashPhase: CGFloat.nan, formLineDashLengths: nil, formColor: color[1])
         let thirdLegend = LegendEntry.init(label: "Average Intake", form: .default, formSize: CGFloat.nan, formLineWidth: CGFloat.nan, formLineDashPhase: CGFloat.nan, formLineDashLengths: nil, formColor: UIColor.black)
        if (num > 0)
        {
            let firstLegend = LegendEntry.init(label: "Current", form: .default, formSize: CGFloat.nan, formLineWidth: CGFloat.nan, formLineDashPhase: CGFloat.nan, formLineDashLengths: nil, formColor: color[0])
            lineChartView.legend.entries = [firstLegend, secondLegend, thirdLegend]
        }
        else
        {
            lineChartView.legend.entries = [secondLegend, thirdLegend]
        }
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


