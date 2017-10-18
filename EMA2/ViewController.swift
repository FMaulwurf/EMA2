//
//  ViewController.swift
//  EMA2
//
//  Created by Felix M. on 17.10.17.
//  Copyright © 2017 Felix M. All rights reserved.
//

import UIKit
import CoreMotion
import Charts

class ViewController: UIViewController {
    
    @IBOutlet weak var xValue: UILabel!
    @IBOutlet weak var yValue: UILabel!
    @IBOutlet weak var zValue: UILabel!
    
    @IBOutlet var barChartView: BarChartView!
    
    let motionManager = CMMotionManager()
    
    var x : Double = 0.0
    var y : Double = 0.0
    var z : Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        barChartView.leftAxis.axisMinimum = -1.0
        barChartView.leftAxis.axisMaximum = 1.0
        
        barChartView.rightAxis.axisMinimum = -1.0
        barChartView.rightAxis.axisMaximum = 1.0
        
        motionManager.accelerometerUpdateInterval = 0.01
        motionManager.startAccelerometerUpdates(to: OperationQueue.main) { accelerometerData, error in
            if let x = accelerometerData?.acceleration.x {
                self.xValue.text = String(describing: x)
                self.x = x
            }
            
            if let y = accelerometerData?.acceleration.y {
                self.yValue.text = String(describing: y)
                self.y = y
            }
            
            if let z = accelerometerData?.acceleration.z {
                self.zValue.text = String(describing: z)
                self.z = z
            }
            
            self.barChartUpdate()
        }
        
    }
    
    func barChartUpdate () {
 
        let xEntry = BarChartDataEntry(x: 1.0, y: self.x)
        let dataSetX = BarChartDataSet(values: [xEntry], label: "X")
        dataSetX.valueColors = [UIColor.red]
        dataSetX.colors = [UIColor.red]
        
        let yEntry = BarChartDataEntry(x: 2.0, y: self.y)
        let dataSetY = BarChartDataSet(values: [yEntry], label: "Y")
        dataSetY.valueColors = [UIColor.green]
        dataSetY.colors = [UIColor.green]
        
        let zEntry = BarChartDataEntry(x: 3.0, y: self.z)
        let dataSetZ = BarChartDataSet(values: [zEntry], label: "Z")
        dataSetZ.valueColors = [UIColor.blue]
        dataSetZ.colors = [UIColor.blue]
        
        let data = BarChartData(dataSets: [dataSetX, dataSetY, dataSetZ])
        barChartView.data = data
        barChartView.chartDescription?.text = "Accelerator Values"
        
        barChartView.notifyDataSetChanged()
    }

}

