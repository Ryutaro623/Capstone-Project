//
//  ViewController.swift
//  Capstone
//
//  Created by 小野沢龍太郎 on 2022-12-17.
//

import UIKit
import CoreBluetooth

class ViewController:UIViewController,CBCentralManagerDelegate,CBPeripheralDelegate{
    var centralManager: CBCentralManager!
    var walkerPeripheral: CBPeripheral!
    var lxCharacteristic: CBCharacteristic!
    var rxCharacteristic: CBCharacteristic!
    
    
    
    @IBOutlet weak var Left: UIButton!
    @IBOutlet weak var Back: UIButton!
    @IBOutlet weak var Right: UIButton!
    @IBOutlet weak var Forward: UIButton!
    @IBOutlet weak var Stop: UIButton!
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
    private func writeValuetoChar( withCharacteristic characteristic: CBCharacteristic, withValue value: Data){
        if characteristic.properties.contains(.writeWithoutResponse) && walkerPeripheral != nil{
            walkerPeripheral.writeValue(value, for: characteristic, type: .withoutResponse)
        }
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Central scanning for peripheral");
                        
        centralManager.scanForPeripherals(withServices: [CBUUID(string: "FFE0")],
                                                options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
    }
}
