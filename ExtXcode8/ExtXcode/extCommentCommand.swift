
//  extCommentCommand.swift
//  ExtXcode8
//
//  Created by 王洪运 on 2016/9/27.
//  Copyright © 2016年 王洪运. All rights reserved.
//

import Foundation
import XcodeKit

class extCommentCommand: NSObject, XCSourceEditorCommand {

    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {

        var lines      = invocation.buffer.lines
        let selections = invocation.buffer.selections

        for selection in selections {

            if let textRange = selection as? XCSourceTextRange, textRange.start.line != lines.count {

                if textRange.start.line == textRange.end.line {
                    let lineIndex = textRange.start.line
                    let line = lines[lineIndex] as! String
                    lines.replaceObject(at: lineIndex, with: select(aLine: line))
                }else {
                    lines = select(lines: lines, inRange: textRange.start.line...textRange.end.line)
                }
            }
        }

        completionHandler(nil)

    }

    func select(lines:NSMutableArray, inRange range:ClosedRange<Int>) -> NSMutableArray {

        var line: String
        var lineCount = 0
        let doubleCommentStr = "//"


        for lineIndex in range.lowerBound...range.upperBound {

            line = lines[lineIndex] as! String

            if line.hasPrefix(doubleCommentStr) {
                lineCount += 1
            }

        }

        for lineIndex in range.lowerBound...range.upperBound {

            line = lines[lineIndex] as! String

            if lineCount == (range.upperBound - range.lowerBound + 1) {
                line.replaceSubrange(doubleCommentStr.startIndex...doubleCommentStr.endIndex, with: "")
            }else {
                line = doubleCommentStr + line
            }

            lines.replaceObject(at: lineIndex, with: line)
            
        }
        
        return lines
    }

    func select(aLine string:String) -> String {

        var line = string

        let doubleCommentStr      = "//"
        let doubleSpaceStr        = "  "
        let newLineStr: Character = "\n"
        let commentStr: Character = "/"
        let spaceStr: Character   = " "
        var charIndex             = line.startIndex

        while line[charIndex] == spaceStr {
            charIndex = line.index(charIndex, offsetBy: 1)
        }

        let currentChar = line[charIndex]

        if currentChar == newLineStr {
            line = doubleCommentStr + line
        }else {

            let nextChar = line[line.index(after: charIndex)]

            if currentChar == commentStr, nextChar == commentStr {

                if charIndex == line.startIndex {
                    line.replaceSubrange(doubleCommentStr.startIndex...doubleCommentStr.endIndex, with: "")
                }else {
                    line.replaceSubrange(charIndex...line.index(after: charIndex), with: doubleSpaceStr)
                }

            }else if currentChar == commentStr, nextChar != commentStr {

                if charIndex == line.startIndex {
                    line.insert(commentStr, at: charIndex)
                }else {
                    line.replaceSubrange(line.index(before: charIndex)...charIndex, with: doubleCommentStr)
                }

            }else {

                if charIndex > line.index(after: line.startIndex) {
                    line.replaceSubrange(doubleSpaceStr.startIndex...doubleSpaceStr.endIndex, with: doubleCommentStr)
                }else {
                    line = doubleCommentStr + line
                }
            }

        }

        return line
    }

}


