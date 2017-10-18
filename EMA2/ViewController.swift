import UIKit
import CoreMotion
import Charts

class ViewController: UIViewController {
    
    @IBOutlet weak var xProgressView: UIProgressView!
    @IBOutlet weak var yProgressView: UIProgressView!
    @IBOutlet weak var zProgressView: UIProgressView!
    
    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var yLabel: UILabel!
    @IBOutlet weak var zLabel: UILabel!
    
    @IBOutlet weak var StartButton: UIButton!
    
    let lengthOfDoubles = 6
    let sampleSpeed = 0.05
    
    let motionManager = CMMotionManager()
    let recordLength: Int = 10
    
    var isRecording: Bool = false
    
    var startOfRecording: Date? = nil
    var timer: Timer? = nil

    var file: FileHandle? = nil {
        didSet {
            isRecording = file != nil
        }
    }
    
    @IBAction func startRecording() {
        if (!isRecording) {
            StartButton.setTitle("0 seconds", for: .normal)
            self.file = FileHandle(forWritingAtPath: "output-" + String(getTimestamp()) + ".csv")
            startOfRecording = Date()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.updateRecordedTime), userInfo: nil, repeats: true)
        }
    }
    
    @objc func updateRecordedTime() {
        let diff: Int = Int(Date().timeIntervalSince(startOfRecording!))
        if (recordLength < diff) {
            recordStop()
            StartButton.setTitle("Start Recording", for: .normal)
        } else {
            StartButton.setTitle(String(diff) + " seconds", for: .normal)
        }
    }
    
    @IBAction func stopRecording() {
        recordStop()
    }

    func recordStop() {
        self.file = nil
        self.timer?.invalidate()
    }
    
    var x : Double = 0.0 {
        didSet(x) {
            let normalizedX: Double = normalizeValue(val: x)
            self.xProgressView.setProgress(Float(normalizedX), animated: false)
            self.xLabel.text = String(x.truncate(places: self.lengthOfDoubles))
        }
    }
    var y : Double = 0.0 {
        didSet(y) {
            let normalizedY: Double = normalizeValue(val: y)
            self.yProgressView.setProgress(Float(normalizedY), animated: false)
            self.yLabel.text = String(y.truncate(places: self.lengthOfDoubles))
        }
    }
    var z : Double = 0.0 {
        didSet(z) {
            let normalizedZ: Double = normalizeValue(val: z)
            self.zProgressView.setProgress(Float(normalizedZ), animated: false)
            self.zLabel.text = String(z.truncate(places: self.lengthOfDoubles))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        motionManager.accelerometerUpdateInterval = self.sampleSpeed
        motionManager.startAccelerometerUpdates(to: OperationQueue.main) { accelerometerData, error in
            if let acc = accelerometerData?.acceleration {
                self.x = acc.x
                self.y = acc.y
                self.z = acc.z
            }
        }
    }
    
}

// Enough for displaying orientation changes
func normalizeValue(val : Double) -> Double {
    return (val + 1.0) / 2.0;
}

func getTimestamp() -> Int {
    return Int(Date().timeIntervalSince1970 * 1000)
}

extension Double {
    func truncate(places : Int) -> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}
