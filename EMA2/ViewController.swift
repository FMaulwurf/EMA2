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
    @IBOutlet weak var recordedTimeLabel: UILabel!
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    
    let motionManager = CMMotionManager()
    let maxDisplayedValues: Double = 1.5
    let updateInterval: Double = 0.025
    let maxDisplayedLength: Int = 10
    let recordLength: Int = 10
    let CSV_DELIMITER: String = ";"
    let CSV_EOL: String = "\n"
    let GRAV_FORCE: Double = 9.81
    let dir = try? FileManager.default.url(for: .documentDirectory,
                                           in: .userDomainMask, appropriateFor: nil, create: true)
    var isRecording: Bool = false
    var startOfRecording: Date? = nil
    var firstTimestamp: Double? = nil
    var timer: Timer? = nil
    var recordedValues: [String] = []
    
    var acc: CMAccelerometerData = CMAccelerometerData() {
        didSet {
            self.xValue.text = truncate(acc.acceleration.x, self.maxDisplayedLength)
            self.yValue.text = truncate(acc.acceleration.y, self.maxDisplayedLength)
            self.zValue.text = truncate(acc.acceleration.z, self.maxDisplayedLength)
            if (isRecording) {
                if (firstTimestamp == nil) {
                    firstTimestamp = acc.timestamp
                }
                let diff: Int = Int((acc.timestamp - firstTimestamp!) * 1000)
                if (diff >= 2000 && diff <= 8000) {
                    self.appendValuesToLog(time: String(diff), x: generateStringForLog(acc.acceleration.x), y: generateStringForLog(acc.acceleration.y), z: generateStringForLog(acc.acceleration.z))
                }
            }
        }
    }
    var file: URL? = nil {
        didSet {
            isRecording = file != nil
        }
    }
    
    func generateStringForLog(_ value:Double) -> String{
        return String(abs(value) * self.GRAV_FORCE).replacingOccurrences(of: ".", with: ",")
    }
    
    @IBAction func startRecording() {
        if (!isRecording) {
            startButton.isEnabled = false
            stopButton.isEnabled = true
            recordedTimeLabel.text = "0s"
            self.appendValuesToLog(time: "timestamp", x: "X", y: "Y", z: "Z")
            let filename = "output_" + String(getFormatedDateForFileName())
            if (dir != nil) {
                self.file = dir?.appendingPathComponent(filename).appendingPathExtension("csv")
            }
            startOfRecording = Date()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.updateRecordedTime), userInfo: nil, repeats: true)
        }
    }
    
    @IBAction func stopRecording() {
        recordStop()
    }
    
    func appendValuesToLog(time: String, x: String, y: String, z: String) {
        recordedValues.append(time + self.CSV_DELIMITER + x + self.CSV_DELIMITER + y + self.CSV_DELIMITER + z + self.CSV_EOL)
    }
    
    func writeToFile() {
        if (self.file != nil) {
            do {
                try recordedValues.joined().write(to: self.file!, atomically: true, encoding: .utf8)
            } catch {
                print("Failed writing to URL: \(String(describing: self.file!)), Error: " + error.localizedDescription)
            }
        }
    }
    
    func recordStop() {
        writeToFile()
        self.file = nil
        self.timer?.invalidate()
        recordedValues = []
        firstTimestamp = nil
        recordedTimeLabel.text = "0s"
        startButton.isEnabled = true
        stopButton.isEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        barChartView.leftAxis.axisMinimum = -self.maxDisplayedValues
        barChartView.leftAxis.axisMaximum = self.maxDisplayedValues
        
        barChartView.rightAxis.axisMinimum = -self.maxDisplayedValues
        barChartView.rightAxis.axisMaximum = self.maxDisplayedValues
        
        barChartView.xAxis.drawLabelsEnabled = false
        
        motionManager.accelerometerUpdateInterval = self.updateInterval
        motionManager.startAccelerometerUpdates(to: OperationQueue.main) { accelerometerData, error in
            if (accelerometerData != nil) {
                self.acc = accelerometerData!
                self.barChartUpdate()
            }
        }
    }
    
    @objc func updateRecordedTime() {
        let diff: Int = Int(Date().timeIntervalSince(startOfRecording!))
        if (self.recordLength < diff) {
            recordStop()
        } else {
            recordedTimeLabel.text = String(diff) + "s"
        }
    }
    
    func barChartUpdate () {
 
        let xEntry = BarChartDataEntry(x: 1.0, y: self.acc.acceleration.x)
        let dataSetX = BarChartDataSet(values: [xEntry], label: "X")
        dataSetX.valueColors = [UIColor.red]
        dataSetX.colors = [UIColor.red]
        
        let yEntry = BarChartDataEntry(x: 2.0, y: self.acc.acceleration.y)
        let dataSetY = BarChartDataSet(values: [yEntry], label: "Y")
        dataSetY.valueColors = [UIColor.green]
        dataSetY.colors = [UIColor.green]
        
        let zEntry = BarChartDataEntry(x: 3.0, y: self.acc.acceleration.z)
        let dataSetZ = BarChartDataSet(values: [zEntry], label: "Z")
        dataSetZ.valueColors = [UIColor.blue]
        dataSetZ.colors = [UIColor.blue]
        
        let data = BarChartData(dataSets: [dataSetX, dataSetY, dataSetZ])
        barChartView.data = data
        barChartView.chartDescription?.text = "Accelerator Values"
        
        barChartView.notifyDataSetChanged()
    }

}

func getFormatedDateForFileName() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd_HH-mm-ss"
    return formatter.string(from: Date())
}

func truncate(_ val: Double, _ length: Int) -> String {
    return String(format: "%." + String(length) + "f", val)
}

