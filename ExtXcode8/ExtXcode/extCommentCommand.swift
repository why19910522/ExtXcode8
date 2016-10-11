
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
                    let line      = lines[lineIndex] as! String
                    lines.replaceObject(at: lineIndex, with: select(aLine: line))
                }else {
                    lines = select(lines: lines, inRange: textRange.start.line...textRange.end.line)
                }
            }
        }

        completionHandler(nil)

    }

    /// 选中了多行要注释的字符串
    ///
    /// - parameter lines: 多行字符串范围
    /// - parameter inRange: 要注释的字符串所在的数组
    ///
    /// - returns: 注释后的字符串所在的数组
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

        let maxCount = range.upperBound - range.lowerBound + 1

        for lineIndex in range.lowerBound...range.upperBound {

            line = lines[lineIndex] as! String

            if lineCount == maxCount {
                line.removeSubrange(doubleCommentStr.startIndex...doubleCommentStr.endIndex)
            }else {
                line = doubleCommentStr + line
            }

            lines.replaceObject(at: lineIndex, with: line)
            
        }
        
        return lines
    }

    /// 选中了一行要注释的字符串
    ///
    /// - parameter aLine: 要注释的字符串
    ///
    /// - returns: 注释后的字符串
    func select(aLine string:String) -> String {

        var line = string

        let doubleCommentStr      = "//"
        let newLineStr: Character = "\n"
        let commentStr: Character = "/"
        let spaceStr: Character   = " "
        var charIndex             = line.startIndex

        while line[charIndex] == spaceStr {
            charIndex = line.index(after: charIndex)
        }

        let currentChar = line[charIndex]

        if currentChar == newLineStr {
            line = doubleCommentStr + line
        }else {

            let nextChar = line[line.index(after: charIndex)]

            if currentChar == commentStr, nextChar == commentStr {
                line.removeSubrange(charIndex...line.index(after: charIndex))
            }else if currentChar == commentStr, nextChar != commentStr {

                if charIndex == line.startIndex {
                    line.insert(commentStr, at: charIndex)
                }else {
                    line.replaceSubrange(line.index(before: charIndex)...charIndex, with: doubleCommentStr)
                }

            }else {
                line = doubleCommentStr + line
            }
        }

        return line
    }

}


