//
//  ViewController.swift
//  QRReader
//
//  Created by Abduraxmon on 09/04/23.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var video = AVCaptureVideoPreviewLayer()
    // 1. session
    let session = AVCaptureSession()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpVideo()
    }
    
    
    func setUpVideo() {
        
        //2. setup video
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        //3. input
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            session.addInput(input)
        } catch {
            fatalError(error.localizedDescription)
        }
        //4. output
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        // 5
        video = AVCaptureVideoPreviewLayer(session: session)
        video.frame = view.layer.bounds
    }
    
    func startRuning() {
        view.layer.addSublayer(video)
        session.startRunning()
    }


    @IBAction func ReadPressed(_ sender: Any) {
        startRuning()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard metadataObjects.count > 0 else {
            return
        }
        
        if let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
            if object.type == AVMetadataObject.ObjectType.qr {
                let aller = UIAlertController(title: "Qr code", message: object.stringValue, preferredStyle: .alert)
                aller.addAction(UIAlertAction(title: "go", style: .cancel, handler: { (action) in
                    guard let str = object.stringValue else {return}
                    guard let url = URL(string: str) else { return }
                    UIApplication.shared.open(url)
                    print(object.stringValue)
                }))
                aller.addAction(UIAlertAction(title: "copy", style: .cancel, handler: { (action) in
                    UIPasteboard.general.string = object.stringValue
                    self.view.layer.sublayers?.removeLast()
                    self.session.stopRunning()
                }))
                present(aller, animated: true)
                
            }
        }
    }
}

