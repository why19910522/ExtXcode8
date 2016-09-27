//
//  extDocumentCommand.swift
//  ExtXcode8
//
//  Created by 王洪运 on 2016/9/27.
//  Copyright © 2016年 王洪运. All rights reserved.
//

import Foundation
import XcodeKit

class extDocumentCommand: NSObject, XCSourceEditorCommand {

    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {


        completionHandler(nil)
    }

}
