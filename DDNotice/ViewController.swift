//
//  ViewController.swift
//  DDNotice
//
//  Created by donglyu on 17/3/18.
//  Copyright © 2017年 donglyu. All rights reserved.
//  todo : 监听点击了关闭按钮的事件。

import Cocoa
import AVFoundation
import NotificationCenter

class ViewController: NSViewController {

    @IBOutlet var TimingContainerView: NSView!
    @IBOutlet weak var TimingNSBox: NSBox!
    @IBOutlet weak var TimingFieldBoxContainerView: NSView!
    @IBOutlet weak var hourLabel: NSTextField!
    @IBOutlet weak var minuteLabel: NSTextField!
    @IBOutlet weak var secondsLabel: NSTextField!
    
    @IBOutlet weak var abortBtn: NSButton!
    @IBOutlet weak var startBtn: NSButton!

    
//    let timer = DDTimer.shared

    var soundPlayer : AVAudioPlayer?

    var isTimeTick = false
    var shadow: NSShadow?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.layer?.backgroundColor = NSColor.black.cgColor
        
        hourLabel.stringValue = "00"
        minuteLabel.stringValue = "00"
        secondsLabel.stringValue = "00"
        
        shadow = NSShadow.init()
        shadow?.shadowColor = NSColor.clear
        shadow?.shadowBlurRadius = 7
        
        hourLabel.wantsLayer = true
        hourLabel.shadow = shadow
        minuteLabel.shadow = shadow;
        minuteLabel.wantsLayer = true
        secondsLabel.shadow = shadow;
        secondsLabel.wantsLayer = true
        self.view.layer?.borderColor = NSColor.red.cgColor
        self.view.layer?.borderWidth = 0
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChanged), name: NSText.didChangeNotification , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appBecomeActive), name: NSNotification.Name("AppBecomeActive"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appResignActive), name: NSNotification.Name("AppResignActive"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TimerUpdateNoti), name: NSNotification.Name(NotiTimerUpdate), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(TimerEndAndNoti), name: NSNotification.Name(NotiTimerEndAction), object: nil)
        
        
//        DDTimer.shared.delegate = self
        
        
    }
    

    

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    // MARK: Main

    @IBAction func abortBtnClick(_ sender: Any) {
        DDTimer.shared.abortSleepTimer()
        // update Label str.
        self.setLabelEditable(editable: true)
        startBtn.title = "开始"
        
        self.view.layer?.borderWidth = 0
    }

    @IBAction func startBtnClick(_ sender: Any) {
        
//        self.view.window?.close()
//        return
        
        if isTimeTick { // 点击暂停按钮
            startBtn.title = "继续"
            DDTimer.shared.PauseTimer()
            isTimeTick = false
            self.ChangeTextFiledShadowColor(color: NSColor.yellow)
            self.view.layer?.borderWidth = 2
        }else{ // 点击开始

            self.ChangeTextFiledShadowColor(color: NSColor.green)
            
            startBtn.title = "暂停"
            
            let hour = hourLabel.integerValue
            let minute = minuteLabel.integerValue
            let seconds = secondsLabel.integerValue
            
            let timeInterval = ((hour*3600)+(minute*60)+seconds)
            if timeInterval > 0 {
                self.setLabelEditable(editable: false)
                DDTimer.shared .runSleepTimer(seconds: NSNumber(value: timeInterval))
            }
        
            isTimeTick = true
            self.view.layer?.borderWidth = 0
            
            
            let isTimeStatusMode = UserDefaults.standard.bool(forKey: UserDefaultSwitchShowStatusTimeView)
            if UserDefaults.standard.object(forKey: UserDefaultSwitchShowStatusTimeView) == nil || isTimeStatusMode  {
                self.view.window?.close()
            }else{
                
            }
            
            
        }
        
        
        
    }

    
}

extension ViewController{
//    override func controlTextDidBeginEditing(_ obj: Notification) {
//        TimingFieldBoxContainerView.layer?.backgroundColor = NSColor.clear.cgColor
//    }
    // MARK: Private
    @objc func textDidChanged(textfield:NSTextField)  {
        if hourLabel.stringValue.count > 2 {
            let index = hourLabel.stringValue.index(hourLabel.stringValue.startIndex, offsetBy: 2)
            let value = hourLabel.stringValue.substring(to: index )
            hourLabel.stringValue = value;
        }
        if minuteLabel.stringValue.count > 2 {
            let index = minuteLabel.stringValue.index(minuteLabel.stringValue.startIndex, offsetBy: 2)
            let value = minuteLabel.stringValue.substring(to: index)
            minuteLabel.stringValue  = value
        }
        if secondsLabel.stringValue.count > 2 {
            let index = secondsLabel.stringValue.index(secondsLabel.stringValue.startIndex, offsetBy: 2)
            let value = secondsLabel.stringValue.substring(to: index)
            secondsLabel.stringValue  = value
        }
        
    }

    func setLabelEditable(editable:Bool)  {
        hourLabel.isEditable = editable
        minuteLabel.isEditable = editable
        secondsLabel.isEditable = editable
        hourLabel.isSelectable = editable
        minuteLabel.isSelectable = editable
        secondsLabel.isSelectable = editable
        
        if editable {
            hourLabel.stringValue = "00"
            minuteLabel.stringValue = "00"
            secondsLabel.stringValue = "00"
        }
        
    }
    
    func ChangeTextFiledShadowColor(color:NSColor){
        self.shadow?.shadowColor = color
        self.hourLabel.shadow = self.shadow
        self.minuteLabel.shadow = self.shadow
        self.secondsLabel.shadow = self.shadow
    }
    
    // MARK: - ---Noti
    
    @objc func appBecomeActive(){
        self.TimingFieldBoxContainerView.layer?.backgroundColor = NSColor.black.cgColor
        
        if isTimeTick{
            
        }else{
            self.ChangeTextFiledShadowColor(color: NSColor.yellow)
        }
    }
    
    @objc func appResignActive(){
        
        if !isTimeTick {
            self.ChangeTextFiledShadowColor(color: NSColor.yellow)
        }
        
    }
    
    
    @objc func TimerUpdateNoti(objc:Notification){
        
        let remaining = objc.object as! CFAbsoluteTime
        
        let hours = Int.init(remaining/3600)
        let temp = remaining.truncatingRemainder(dividingBy: 3600)
        let minutes =  Int.init(temp/60)
        let seconds = Int.init(remaining.truncatingRemainder(dividingBy: 60)) //%60
        
        
        //        print("hours: \(hours) ,minutes: \(minutes),seconds: \(seconds)")
        
        hourLabel.stringValue = String.init(format: "%0.2d", hours)
        minuteLabel.stringValue = String.init(format: "%0.2d", minutes)
        secondsLabel.stringValue = String.init(format: "%0.2d", seconds)

        
    }
    
    @objc func TimerEndAndNoti(){
        
        setLabelEditable(editable: true)
        self.view.wantsLayer = true
        
        self.ChangeTextFiledShadowColor(color: NSColor.red)
        
        let isPlaySounds = UserDefaults.standard.integer(forKey:UserDefaultIsPlaySounds)
        
        if isPlaySounds == 1 || UserDefaults.standard.object(forKey: UserDefaultIsPlaySounds) == nil {
            self.prepareSound()
            self.playSound()
        }
        startBtn.title = "开始"
        isTimeTick = false
        
        
        let action = SliceAlertManager.sharedManager.PopNormalAlertNoticeView()
        
        if action == NSApplication.ModalResponse.alertFirstButtonReturn {
            self.ChangeTextFiledShadowColor(color: NSColor.yellow)
        }
    }
    
    // MARK: - Timer Delegate
//    func updateRemainingTime(remaining: CFAbsoluteTime) {
//        let hours = Int.init(remaining/3600)
//        let temp = remaining.truncatingRemainder(dividingBy: 3600)
//        let minutes =  Int.init(temp/60)
//        let seconds = Int.init(remaining.truncatingRemainder(dividingBy: 60)) //%60
//
//
////        print("hours: \(hours) ,minutes: \(minutes),seconds: \(seconds)")
//
//        hourLabel.stringValue = String.init(format: "%0.2d", hours)
//        minuteLabel.stringValue = String.init(format: "%0.2d", minutes)
//        secondsLabel.stringValue = String.init(format: "%0.2d", seconds)
//
//        // uij
//    }
    
//
//    func TimerEndAction() {
//        setLabelEditable(editable: true)
//        self.view.wantsLayer = true
//
//        self.ChangeTextFiledShadowColor(color: NSColor.red)
//
//        let isPlaySounds = UserDefaults.standard.integer(forKey:UserDefaultIsPlaySounds)
//
//        if isPlaySounds == 1 || UserDefaults.standard.object(forKey: UserDefaultIsPlaySounds) == nil {
//            self.prepareSound()
//            self.playSound()
//        }
//
//
//        // MARK: Notification
//
////        let noti = NSNotification.init(name: NSNotification.Name(rawValue: "notiName"), object: nil)
////        NSNotification.init
////        // Notification End
//
//        startBtn.title = "开始"
//        isTimeTick = false
//
//
//        let action = SliceAlertManager.sharedManager.PopNormalAlertNoticeView()
//
//        if action == NSApplication.ModalResponse.alertFirstButtonReturn {
//            self.ChangeTextFiledShadowColor(color: NSColor.yellow)
//        }
//
//
//    }


}

extension ViewController{
    // MARK: - --Music About!
    
    func prepareSound() {
        
        if soundPlayer != nil {
            return
        }
        
        guard let audioFileUrl = Bundle.main.url(forResource: "夏日午后的农庄内音效",
                                                 withExtension: "wav") else {
                                                    return
        }
        
        do {
            soundPlayer = try AVAudioPlayer(contentsOf: audioFileUrl)
            soundPlayer?.prepareToPlay()
        } catch {
            print("Sound player not available: \(error)")
        }
    }
    
    func playSound() {
        soundPlayer?.play()
    }

    
    /*
     1. 选择本地音乐， 复制到沙盒文件中... // 文件选择框，获取路劲
     2. 播放音乐
     */
    
    
    //5-5 .play
    func prepareAndPlaySound(filePath: String) {
        
        //
        
    }
}
