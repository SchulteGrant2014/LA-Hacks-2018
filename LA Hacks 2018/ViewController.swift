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
    

    var receipts: [Receipt] = []        // full list of receipts, size ranges from 0 to 6
    var pastReceipts: [Receipt] = []    // list of past receipts, size ranges from 0 to 5
    var currentReceipt: Receipt?        // current receipts,      size ranges from 0 to 1
    var idealRelativeNutrientPerc: [String:Double] = [ "Protein":11.34594, "Fats":13.570634, "Carbohydrates":61.179088, "Sugars":16.896552, "Dietary Fiber":7.007786 ]
    // Nutrients = ["Protein","Fats","Carbohydrates","Sugars","Dietary Fiber"]
    var lineChartData = LineChartData()
    
    // chart stuff
    var pieChartView: PieChartView!
    var lineChartView: LineChartView!
    
    //categories of nutrients
    let nutrients = ["Protein", "Fats", "Carbohydrates", "Sugars", "Dietary Fiber"]
    //daily intake pie chart
    var piePercentage = [0.0, 0.0, 0.0, 0.0, 0.0]
    
    //ratio of intake vs average
    var linePercentage = [0.0, 0.0, 0.0, 0.0, 0.0]
    
    //previous ratio of intake vs average
    var prevPercentage = [0.0, 0.0, 0.0, 0.0, 0.0]
    
    //base line: average intake for each nutrient
    let baseline = [1.0, 1.0, 1.0, 1.0, 1.0]
    
    
    // -------------------- Default functions --------------------
    
    func saveUserDefaults() {
        let defaults = UserDefaults.standard
        //print("AAAAAAAAhhhhhhhh")
        var primitives: [[Any]] = []
        for receipt in receipts {
            primitives.append(receipt.convertToPrimitives())
        }
        
        // Go through all primitive properties, save in a list in User Defaults
        var i: Int = 1;
        for primitive_receipt in primitives {
            var nutrWeights: [String:Double] = primitive_receipt[0] as! [String:Double]
            var nutrFacts: [String:Double] = primitive_receipt[1] as! [String:Double]
            var items: [[Any]] = primitive_receipt[2] as! [[Any]]
            var itemNames: [String] = []
            var itemKeys: [String] = []
            var itemNutrDicts: [[String:Double]] = []
            for item in items {
                itemNames.append(item[0] as! String)
                itemKeys.append(item[1] as! String)
                itemNutrDicts.append(item[2] as! [String:Double])
            }
            var receiptKey: String = "Receipt-" + String(i) + "-"
            defaults.set(nutrWeights, forKey: (receiptKey + "nutrWeights"))
            defaults.set(nutrFacts, forKey: (receiptKey + "nutrFacts"))
            defaults.set(itemNames, forKey: (receiptKey + "itemNames"))
            defaults.set(itemKeys, forKey: (receiptKey + "itemKeys"))
            defaults.set(itemNutrDicts, forKey: (receiptKey + "itemNutrDicts"))
            i += 1
        }
        defaults.set(i, forKey: "NumberOfReceipts")
        
        //print("AAAAAAAAAA Saved user defaults, number of receipts = " + String(self.receipts.count))
    }
    
    
    func loadUserDefaults() {
        let defaults = UserDefaults.standard
        var receiptList: [Receipt] = []
        if let numReceipts = defaults.value(forKey: "NumberOfReceipts") as? Int {
            for i in 1...(numReceipts) {  // Get all receipts back into normal form
                
                var receiptKey: String = "Receipt-" + String(i) + "-"
                if let weights = defaults.value(forKey: (receiptKey + "nutrWeights")) as? [String:Double] {
                    var nutrWeights: [String:Double] = weights
                    var nutrFacts: [String:Double] = defaults.value(forKey: (receiptKey + "nutrFacts")) as! [String:Double]
                    var itemNames: [String] = defaults.value(forKey: (receiptKey + "itemNames")) as! [String]
                    var itemKeys: [String] = defaults.value(forKey: (receiptKey + "itemKeys")) as! [String]
                    var itemNutrDicts: [[String:Double]] = defaults.value(forKey: (receiptKey + "itemNutrDicts")) as! [[String:Double]]
                    
                    var newReceipt: Receipt = Receipt(nutrWeights: nutrWeights, nutrFacts: nutrFacts, itemNames: itemNames, itemKeys: itemKeys, itemNutrDicts: itemNutrDicts)
                    
                    receiptList.append(newReceipt)
                }
            }
        }
        receipts = receiptList  // Update the receipts to reflect those in UserDefaults data
    }
    
    
    func clearUserDefaults() {
        let defaults = UserDefaults.standard
        defaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        defaults.synchronize()
        //print("AAAAAAAAAA User Defaults have been cleared, number of Receipts = " + String(self.receipts.count))
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Load user defaults
        clearUserDefaults()
        //loadUserDefaults()
        //print("AAAAAA" + String(self.receipts.count))
        
        //charts
        
        //set position and bounds
        pieChartView = PieChartView(frame: CGRect(x: 70, y: 90, width: 225, height: 225))
        self.view.addSubview(pieChartView!)
        lineChartView = LineChartView(frame: CGRect(x: 52.5, y: 350, width: 270, height: 270))
        self.view.addSubview(lineChartView!)
        let colors = [UIColor(red: 51/255, green: 183/255, blue: 148/255, alpha: 1), UIColor(red: 78/255, green: 102/255, blue: 191/255, alpha: 1)]
        
        //call methods that put data into charts
        setLineChart(dataPoints: nutrients, prevValues: prevPercentage, baseValues: baseline)
        addLegend(num: receipts.count, color: colors)
        if receipts.count == 0 {
            setEmptyPieChart()
        }
        else{
            setPieChart(dataPoints: nutrients, values: piePercentage)
            addCurrentLine(values: linePercentage)
        }
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
        
        print("PREVIOUS")
        var prevChartEntries: [ChartDataEntry] = []
        var baseLineEntries: [ChartDataEntry] = []
        
        for i in 0..<prevValues.count {
            let dataEntry3 = ChartDataEntry(x: Double(i), y: prevValues[i])
            prevChartEntries.append(dataEntry3)
            print(prevChartEntries[i])
        }
        
        //store base values in an array of entries
        for i in 0..<baseValues.count {
            let dataEntry4 = ChartDataEntry(x: Double(i), y: baseValues[i])
            baseLineEntries.append(dataEntry4)
             print(baseLineEntries[i])
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
        lineChartData = LineChartData()
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
        lineChartView.data = lineChartData
    }
    
    func addCurrentLine(values: [Double])
    {
        
        print("dfadfdsfdsffs")
        var lineChartEntries: [ChartDataEntry] = []
        
        //store values in an array of entries
        for i in 0..<values.count {
            let dataEntry2 = ChartDataEntry(x: Double(i), y: values[i])
            lineChartEntries.append(dataEntry2)
            //print("ChartDataentry, x: " + String(i) + ", y" + values[i])
        }
        
        let line1 = LineChartDataSet(values: lineChartEntries, label: nil)
        
        //visual formatting for lines
        line1.valueFont = UIFont(name: "Verdana", size: 8.0)!
        let lineColor = UIColor(red: 51/255, green: 183/255, blue: 148/255, alpha: 1)
        line1.colors = [lineColor]
        
        //add data to view
        //let lineChartData = LineChartData()//dataSet: line1)
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
        //print("AAAAAAAA Entered unwind segue")
        if let sourceViewController = sender.source as? AddImageViewController {
            //print("AAAAAAAAA Entered first if in unwind")
            if let image = sourceViewController.ImageDisplay.image {

                //print("AAAAAAAAAA Entered image if in unwind")
                let newReceipt: Receipt = Receipt(image: image)
                //print("AAAAAAAAA Finished making new receipt in unwind")
                if receipts.count == 5 {
                    receipts.removeFirst(1)
                    receipts.append(newReceipt)
                    //print("AAAAAAA About to save user defaults in if...")
                    saveUserDefaults()
                } else {
                    receipts.append(newReceipt)
                    //print("AAAAAAA About to save user defaults in else...")
                    saveUserDefaults()
                }
                
                // Update the pie chart with the most recent receipt data
                var pieChartDataNew: [Double] = []
                for nutr in nutrients {
                    if let newNutrient = newReceipt.nutritionFactsTotal[nutr]{
                        pieChartDataNew.append(newNutrient)
                    }
                    else{
                        pieChartDataNew.append(0)
                    }
                }
                self.piePercentage = pieChartDataNew
                setPieChart(dataPoints: nutrients, values: pieChartDataNew)  // Reload the pie chart
                
                // Update scatterplot to reflect history of receipts
                var scatterDataNew: [Double] = []
                for nutr in nutrients {
                    var sumOfData: Double = 0.0
                    for receipt in self.receipts {
                        if let receiptData = receipt.nutritionFactsTotal[nutr] {
                            sumOfData += receiptData
                        }
                        //print(receipt.nutritionFactsTotal["Car])
                    }
                    var average: Double = sumOfData / Double(self.receipts.count)
                    var ratio: Double = 1
                    if let idealData = idealRelativeNutrientPerc[nutr] {
                        ratio = average / idealData
                    } else {
                        ratio = 0
                    }
                    scatterDataNew.append(ratio)
                }
                
                var prevDataNew: [Double] = [0.0, 0.0, 0.0, 0.0, 0.0]
                
                for i in 0..<receipts.count
                {
                    var j = 0
                    print("2222")
                    for nutr in self.nutrients {
                        if let receiptNutrValue: Double = receipts[i].nutritionFactsTotal[nutr]{
                            print("3333")
                            let idealNutrValue: Double = idealRelativeNutrientPerc[nutr]!
                            let ratio: Double = receiptNutrValue / idealNutrValue
                            if (j < prevDataNew.count){
                                prevDataNew[j] = (prevDataNew[j]+ratio)
                            }
                        }
                        j = j+1
                    }
                }
                
                for x in 0..<prevDataNew.count
                {
                    //average all the nutrient ratios for every receipt
                    prevDataNew[x] = (prevDataNew[x])/(Double(receipts.count))
                }
                self.linePercentage = scatterDataNew
                self.prevPercentage = prevDataNew
                setLineChart(dataPoints: nutrients, prevValues: prevPercentage, baseValues: baseline)
                addCurrentLine(values: linePercentage)
                //self.viewDidLoad()
                
                ////
                
                
                // Update pie chart data to data from new receipt
                /*var pieDataNew: [Double] = []
                var lineDataNew: [Double] = []
                //var prevDataNew: [Double] = []
                
                for nutr in self.nutrients {
                    if let receiptNutrValue = newReceipt.nutritionFactsTotal[nutr] {
                        pieDataNew.append(receiptNutrValue)
                        let idealNutrValue: Double = idealRelativeNutrientPerc[nutr]!
                        let ratio: Double = receiptNutrValue / idealNutrValue
                        lineDataNew.append(ratio)
                    } else {
                        pieDataNew.append(0)
                        lineDataNew.append(0)
                    }
                    
                }
                /*for i in 0...receipts.count
                {
                    var j = 0
                    for nutr in self.nutrients {
                        let receiptNutrValue: Double = receipts[i].nutritionFactsTotal[nutr]!
                        let idealNutrValue: Double = idealRelativeNutrientPerc[nutr]!
                        let ratio: Double = receiptNutrValue / idealNutrValue
                        prevDataNew[j] = prevDataNew[j]+ratio
                        j = j+1
                    }
                }*/
                
                self.piePercentage = pieDataNew
                self.linePercentage = lineDataNew
                //self.prevPercentage = prevDataNew
                
                setPieChart(dataPoints: nutrients, values: piePercentage)
                
                // Update scatterplot to data from new receipt (new line) and history (old line)
                setLineChart(dataPoints: nutrients, prevValues: prevPercentage, baseValues: baseline)
                addCurrentLine(values: linePercentage)*/
            }
            }
        }
    }
    
    


