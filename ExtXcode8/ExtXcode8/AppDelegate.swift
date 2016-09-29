
//  AppDelegate.swift
//  ExtXcode8
//
//  Created by 王洪运 on 2016/9/27.
//  Copyright © 2016年 王洪运. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

          


    func applicationDidFinishLaunching(_ aNotification: Notification) {
//      I/nsert   code here to initialize your application


        let dd = "fasf- (void)fasf"
        print(dd.hasMethod())

    }


    func applicationWillTerminate(_ aNotification: Notification) {
    //Insert code here to tear down your/ application
    }




    func `var` () -> Void {

    }


    func sfasf(fsdf: String) -> String {
        return ""
    }


}

extension String {
    func hasMethod() -> Bool {
        let str     = replacingOccurrences(of: " ", with: "")
        let pattern = "[-,+]\\(\\S*\\)"
        let regular = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)

        let results = regular.matches(in: str, options: .reportProgress, range: NSMakeRange(0, str.characters.count))

        if results.count == 1 {

            if let range = results.first?.range, range.location == 0 {
                return true
            }
        }
        
        return false
    }
}


