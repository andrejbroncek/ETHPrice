//
//  AppDelegate.swift
//  ETHPrice
//
//  Created by Andrej Broncek on 29/05/2017.
//  Copyright © 2017 andrejbroncek. All rights reserved.
//

import Cocoa
import Foundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let statusBar = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    let menu = NSMenu()
    
    enum Currency {
        case usd, eur, btc
    }
    
    var current = Currency.eur
    
    var eurValue = 0.0
    var usdValue = 0.0
    var btcValue = 0.0
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        getEthPrice()
        
        var refreshTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(refreshPrice), userInfo: nil, repeats: true)
        
        
        menu.addItem(NSMenuItem(title: "🇪🇺 \(eurValue) €", action: #selector(changedToEuro), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "🇺🇸 \(usdValue) $", action: #selector(changedToDollar), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "💰 \(btcValue) BTC", action: #selector(changedToBtc), keyEquivalent: ""))

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Refresh", action: #selector(refreshPrice), keyEquivalent: "r"))
        menu.addItem(NSMenuItem(title: "ETH on CryptoCompare", action: #selector(openCryptoCompare), keyEquivalent: "c"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        
        statusBar.menu = menu
        
        self.statusBar.button?.title = "🇪🇺 \(eurValue) €"
    }
    
    func refreshPrice() {
        getEthPrice()
    }
    
    func quit() {
        NSApplication.shared().terminate(self)
    }
    
    func openCryptoCompare() {
        if let url = URL(string: "https://www.cryptocompare.com/coins/eth/overview/EUR"), NSWorkspace.shared().open(url) {
            print("https://www.cryptocompare.com/coins/eth/overview/EUR opened")
        }
    }
    
    func getEthPrice() {
        let url = URL(string: "https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=BTC,USD,EUR")
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print("error")
            }else{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                    
                    self.usdValue = json["USD"] as! Double
                    self.eurValue = json["EUR"] as! Double
                    self.btcValue = json["BTC"] as! Double
                    
                    switch (self.current) {
                    case .eur:
                        self.statusBar.button?.title = "🇪🇺 \(self.eurValue) €"
                    break;
                        
                    case .usd:
                        self.statusBar.button?.title = "🇺🇸 \(self.usdValue) $"
                        break;
                        
                    case .btc:
                        self.statusBar.button?.title = "💰 \(self.btcValue) BTC"
                        break;
                        
                    default:
                        self.statusBar.button?.title = "🇪🇺 \(self.eurValue) €"
                        break;
                        
                    }
                        
                    self.menu.item(at: 0)?.title = "🇪🇺 \(self.eurValue) €"
                    self.menu.item(at: 1)?.title = "🇺🇸 \(self.usdValue) $"
                    self.menu.item(at: 2)?.title = "💰 \(self.btcValue) BTC"
                    
                    
                    OperationQueue.main.addOperation({
                        print("\(self.usdValue) $ | \(self.eurValue) € | \(self.btcValue) BTC")
                    })
                    
                }catch let error as NSError{
                    print(error)
                }
            }
        }).resume()
    }
    
    func changedToEuro() {
        self.current = Currency.eur
        getEthPrice()
        self.statusBar.button?.title = "🇪🇺 \(self.eurValue) €"
    }
    
    func changedToDollar() {
        self.current = Currency.usd
        getEthPrice()
        self.statusBar.button?.title = "🇺🇸 \(self.usdValue) $"
    }

    func changedToBtc() {
        self.current = Currency.btc
        getEthPrice()
        self.statusBar.button?.title = "💰 \(self.btcValue) BTC"
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    
}

