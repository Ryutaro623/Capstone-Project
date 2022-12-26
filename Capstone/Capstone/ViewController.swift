//
//  ViewController.swift
//  Capstone
//
//  Created by 小野沢龍太郎 on 2022-12-17.
//

import UIKit
import CoreBluetooth
import InstantSearchVoiceOverlay

class ViewController:UIViewController,CBCentralManagerDelegate,CBPeripheralDelegate{
    let voiceOverlay = VoiceOverlayController()
    var centralManager: CBCentralManager!
    var walkerPeripheral: CBPeripheral!
    var lxCharacteristic: CBCharacteristic!
    var rxCharacteristic: CBCharacteristic!
    
    @IBOutlet weak var Voice: UIButton!
    @IBOutlet weak var Left: UIButton!
    @IBOutlet weak var Back: UIButton!
    @IBOutlet weak var Right: UIButton!
    @IBOutlet weak var Stop: UIButton!
    @IBOutlet weak var Forward: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        // Do any additional setup after loading the view.
    }
    func startScanning()->Void{
        //Start Scanning
        centralManager?.scanForPeripherals(withServices:[CBUUID(string: "FFE0")])
    }
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state{
        case .poweredOff:
            print("Is Powered Off.")
        case .poweredOn:
            print("Is Powered On.")
            startScanning()
        case .unsupported:
            print("Is Unsupported.")
        case .unauthorized:
            print("Is Unauthorized.")
        case .unknown:
            print("Unknown")
        case .resetting:
            print("Resetting")
        @unknown default:
            print("Error")
            
            
        }
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        centralManager.stopScan();
        walkerPeripheral = peripheral
        walkerPeripheral.delegate = self
        
        centralManager.connect(walkerPeripheral!, options: nil)
        
        
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if walkerPeripheral == self.walkerPeripheral{
            print("Connected your walking robot!!!!!!!!!!!!")
            walkerPeripheral.discoverServices([CBUUID(string: "FFE0")])
        }
        
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("*******************************************************")
        
        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        guard let services = peripheral.services else {
            return
        }
        //We need to discover the all characteristic
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
        print("Discovered Services: \(services)")
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        guard let characteristics = service.characteristics else {
            return
        }
        
        print("Found \(characteristics.count) characteristics.")
        
        for characteristic in characteristics {
            
            if characteristic.uuid.isEqual(CBUUID(string: "FFE1"))  {
                
                rxCharacteristic = characteristic
                
                peripheral.setNotifyValue(true, for: rxCharacteristic!)
                peripheral.readValue(for: characteristic)
                
                print("RX Characteristic: \(rxCharacteristic.uuid)")
                
            }
            
            if characteristic.uuid.isEqual(CBUUID(string: "FFE1")){
                
                lxCharacteristic = characteristic
                
                print("TX Characteristic: \(lxCharacteristic.uuid)")
                
                
                Forward.isEnabled = true;
                Back.isEnabled = true;
                Right.isEnabled = true;
                Left.isEnabled = true;
                Stop.isEnabled = true;
                Voice.isEnabled = true;
            }
        }
    }
    @IBAction func Stopb(_ sender: Any) {
        let move:UInt8 = UInt8(0);
        writeValuetoChar(withCharacteristic: rxCharacteristic, withValue: Data([move]))
        print("Stop")
    }
    
    @IBAction func Forwardb(_ sender: Any) {
        let move:UInt8 = UInt8(1);
        writeValuetoChar(withCharacteristic: rxCharacteristic, withValue: Data([move]))
        print("Forward")
    }
    
    @IBAction func RightB(_ sender: Any) {
        let move:UInt8 = UInt8(2);
        writeValuetoChar(withCharacteristic: rxCharacteristic, withValue: Data([move]))
        print("Right")
    }
    
    @IBAction func Backb(_ sender: Any) {
        let move:UInt8 = UInt8(3);
        writeValuetoChar(withCharacteristic: rxCharacteristic, withValue: Data([move]))
        print("Back")
    }
    
    @IBAction func Leftb(_ sender: Any) {
        let move:UInt8 = UInt8(4);
        writeValuetoChar(withCharacteristic: rxCharacteristic, withValue: Data([move]))
        print("Left")
    }
    
    @IBAction func VoiceC(_ sender: Any) {
        let move:UInt8 = UInt8(0);
        self.writeValuetoChar(withCharacteristic: self.rxCharacteristic, withValue: Data([move]));
        voiceOverlay.settings.autoStop = false
        voiceOverlay.settings.layout.inputScreen.titleInProgress = "Sending..."


        voiceOverlay.start(on: self, textHandler: {text, final, _ in
            if(final){
                let move:UInt8 = UInt8(0);
                self.writeValuetoChar(withCharacteristic: self.rxCharacteristic, withValue: Data([move]));
                print("final:\(text)")
            } else {
                let sentence = text;
                let words = sentence.byWords;
                let lastwords = words.last;
                if(lastwords?.contains("Forward") ?? false||lastwords?.contains("forward") ?? false){
                    let move:UInt8 = UInt8(1);
                    self.writeValuetoChar(withCharacteristic: self.rxCharacteristic, withValue: Data([move]));
                    print("move forward")
                } else if(lastwords?.contains("right") ?? false||lastwords?.contains("Right") ?? false){
                    let move:UInt8 = UInt8(2);
                    self.writeValuetoChar(withCharacteristic: self.rxCharacteristic, withValue: Data([move]));
                    print("turn right")
                } else if(lastwords?.contains("left") ?? false||lastwords?.contains("Left") ?? false){
                    let move:UInt8 = UInt8(4);
                    self.writeValuetoChar(withCharacteristic: self.rxCharacteristic, withValue: Data([move]));
                    print("turn left")
                } else if(lastwords?.contains("Backward") ?? false||lastwords?.contains("backward") ?? false){
                    let move:UInt8 = UInt8(3);
                    self.writeValuetoChar(withCharacteristic: self.rxCharacteristic, withValue: Data([move]));
                    print("move backward")
                } else if(lastwords?.contains("Stop") ?? false||lastwords?.contains("stop") ?? false){
                    let move:UInt8 = UInt8(0);
                    self.writeValuetoChar(withCharacteristic: self.rxCharacteristic, withValue: Data([move]))
                    print("stop moving")
                }else{
                    print("In progress")
                }
                    
            }
            
        },
                errorHandler: {error in })
        
    }
    private func writeValuetoChar( withCharacteristic characteristic: CBCharacteristic, withValue value: Data){
        if characteristic.properties.contains(.writeWithoutResponse) && walkerPeripheral != nil{
            walkerPeripheral.writeValue(value, for: characteristic, type: .withoutResponse)
        }
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        Forward.isEnabled = false;
        Back.isEnabled = false;
        Right.isEnabled = false;
        Left.isEnabled = false;
        Stop.isEnabled = false;
        Voice.isEnabled = false;
        print("Central scanning for peripheral");
                        
        centralManager.scanForPeripherals(withServices: [CBUUID(string: "FFE0")],
                                                options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
    }
    
}

extension StringProtocol {
    var byWords: [SubSequence] {
        var byWords: [SubSequence] = []
        enumerateSubstrings(in: startIndex..., options: .byWords) { _, range, _, _ in
            byWords.append(self[range])
        }
        return byWords
    }
}
