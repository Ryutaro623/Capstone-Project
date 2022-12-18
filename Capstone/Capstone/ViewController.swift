//
//  ViewController.swift
//  Capstone
//
//  Created by 小野沢龍太郎 on 2022-12-17.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBPeripheralDelegate{
    var centralManager: CBCentralManager!
    var walkerPeripheral: CBPeripheral!

    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        // Do any additional setup after loading the view.
    }
    func startScanning()->Void{
        //Start Scanning
        centralManager?.scanForPeripherals(withServices:[CBUUID(string: "FFE0")])
    }


}
extension ViewController: CBCentralManagerDelegate{
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
}

