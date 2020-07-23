
//this class responsible for scanning and scanner view

import AVFoundation
import UIKit

protocol ScannerDelegate {
    func failed()
    func success(code:String)
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    //variables
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var delegate : ScannerDelegate!
    var qrCodeFrameView: UIView?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setting background color
        view.backgroundColor = UIColor.black
        
        //initianlizing capture session
        captureSession = AVCaptureSession()
        
        //declare capture device
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        //initializing capture device
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        //adding capture device
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        //meta data is use for code type, we are reading every type of code including qr and bar and others
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.code128,
                                                  .code39,
                                                  .code39Mod43,
                                                  .code93,
                                                  .ean13,
                                                  .ean8,
                                                  .interleaved2of5,
                                                  .itf14,
                                                  .pdf417,
                                                  .upce]
        } else {
            failed()
            return
        }
        
        //setting preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        //starts scanning
        startScanning()
        
    }
    
    //Mark:- function which handle scanning
    func startScanning(){
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
        qrCodeFrameView?.removeFromSuperview()
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubviewToFront(qrCodeFrameView)
        }
    }
    
    //Mark:- function called when something failed
    func failed() {
        //        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        //        ac.addAction(UIAlertAction(title: "OK", style: .default))
        //        present(ac, animated: true)
        captureSession = nil
        delegate.failed()
    }
    
    //Mark:- view will appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //calling start scanning
        startScanning()
    }
    
    //Mark:- calls on view disappears
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    //Mark:- capture settion delegate, it called up when reading finished
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject

        let barCodeObject = previewLayer?.transformedMetadataObject(for: metadataObj)

        qrCodeFrameView?.frame = barCodeObject!.bounds

        //decoding code
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
        
        // dismiss(animated: true)
    }
    
    //Mark:- code found
    func found(code: String) {
        print(code)
        delegate.success(code: code)
    }
    
    //
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //Mark:- supprted orientation
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    //right now app supports for portait mode only, before initializing the app, if phone in landscape mode then view of capture becomes annonying
    
//    public func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
//        layer.videoOrientation = orientation
//        previewLayer?.frame = self.view.frame
//    }
//    
//    override func viewDidLayoutSubviews() {
//      super.viewDidLayoutSubviews()
//      
//      if let connection =  self.previewLayer?.connection  {
//        let currentDevice: UIDevice = UIDevice.current
//        let orientation: UIDeviceOrientation = currentDevice.orientation
//        let previewLayerConnection : AVCaptureConnection = connection
//        
//        if previewLayerConnection.isVideoOrientationSupported {
//          switch (orientation) {
//          case .portrait:
//            updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
//            break
//          case .landscapeRight:
//            updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft)
//            break
//          case .landscapeLeft:
//            updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight)
//            break
//          case .portraitUpsideDown:
//            updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown)
//            break
//          default:
//            updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
//            break
//          }
//        }
//      }
//    }
    
}
