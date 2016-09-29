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

    var addLineCount    = 0

    let spaceChar       = " "
    let fourSpaceStr    = "    "
    let threeCommentStr = "///"
    let descriptionStr  = "<#Description#>"
    let parameterStr    = " - parameter "
    let returnsStr  = " - returns: "

    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {

        let lines      = invocation.buffer.lines
        let selections = invocation.buffer.selections

        for selection in selections {

            if let textRange = selection as? XCSourceTextRange,
                textRange.start.line != lines.count {

                var lineIndex = 0

                if textRange.start.line == textRange.end.line {

                    lineIndex = textRange.start.line + addLineCount

                    let line          = lines[lineIndex] as! String
                    let nextLineIndex = lineIndex + 1
                    let nextLine      = lines[nextLineIndex] as! String

                    if line.hasVarOrLet() {
                        insertVarOrLetDoc(at: lineIndex, withLine: line, inLines: lines)
                    }else if line.hasFuncMethod() {
                        insertFuncDoc(at: lineIndex, withLine: line, inLines: lines)
                    }else if nextLine.hasVarOrLet() {
                        insertVarOrLetDoc(at: nextLineIndex, withLine: nextLine, inLines: lines)
                    }else if nextLine.hasFuncMethod() {
                        insertFuncDoc(at: nextLineIndex, withLine: nextLine, inLines: lines)
                    }else if line.hasProperty() {
                        insertPropertyDoc(at: lineIndex, withLine: line, inLines: lines)
                    }else if line.hasMethod() {
                        insertMethodDoc(at: lineIndex, withLine: line, inLines: lines)
                    }else if nextLine.hasProperty() {
                        insertPropertyDoc(at: nextLineIndex, withLine: nextLine, inLines: lines)
                    }else if nextLine.hasMethod() {
                        insertMethodDoc(at: nextLineIndex, withLine: nextLine, inLines: lines)
                    }

                }else {

                    for index in textRange.start.line...textRange.end.line {

                        lineIndex = index + addLineCount
                        let line  = lines[lineIndex] as! String

                        if line.hasVarOrLet() {
                            insertVarOrLetDoc(at: lineIndex, withLine: line, inLines: lines)
                        }else if line.hasFuncMethod() {
                            insertFuncDoc(at: lineIndex, withLine: line, inLines: lines)
                        }else if line.hasProperty() {
                            insertPropertyDoc(at: lineIndex, withLine: line, inLines: lines)
                        }else if line.hasMethod() {
                            insertMethodDoc(at: lineIndex, withLine: line, inLines: lines)
                        }
                    }
                }

                addLineCount = 0
            }
        }

        completionHandler(nil)
    }

    func insertMethodDoc(at index: Int, withLine line: String, inLines lines: NSMutableArray) {

        var insertParamDocCount = 0

        var startIndex = line.range(of: "(")!.lowerBound
        var tempStr    = line.substring(from: startIndex).replacingOccurrences(of: "{", with: " ")
        startIndex     = tempStr.index(after: tempStr.startIndex)
        var endIndex   = tempStr.range(of: ")")!.lowerBound


        let returnTypeStr = tempStr.substring(with: startIndex..<endIndex).trimmingCharacters(in: .whitespacesAndNewlines)
        let prefixReturnstr  = threeCommentStr + " @return "
        if returnTypeStr != "void" {
            let returnValueStr = prefixReturnstr + "<#return value description#>"

            if hasDoc(at: index-1, withPrefix: prefixReturnstr, inLines: lines) {
                return
            }

            lines.insert(returnValueStr, at: index)
            lines.insert(threeCommentStr, at: index)
            addLineCount += 2
        }

        let prefixParam = threeCommentStr + " @param "
        startIndex = tempStr.index(after: endIndex)
        tempStr    = tempStr.substring(from: startIndex)

        while tempStr.contains(")") {

            endIndex = tempStr.range(of: ")", options: [.backwards])!.lowerBound

            var paramName = tempStr.substring(from: endIndex).replacingOccurrences(of: ")", with: "")
            paramName     = paramName.trimmingCharacters(in: .whitespacesAndNewlines)
            if hasDoc(at: index-1, withPrefix: prefixParam + paramName, inLines: lines) {
                return
            }

            let paramDoc = prefixParam + paramName + " " + "<#\(paramName) description#>"

            lines.insert(paramDoc, at: index)
            insertParamDocCount += 1

            tempStr = tempStr.substring(to: endIndex)
            endIndex = tempStr.range(of: ":", options: [.backwards])!.lowerBound
            tempStr = tempStr.substring(to: endIndex).trimmingCharacters(in: .whitespacesAndNewlines)

            if let tempIndex = tempStr.range(of: " ", options: [.backwards])?.lowerBound {
                tempStr = tempStr.substring(to: tempIndex)
            }
        }

        if insertParamDocCount > 0 {
            lines.insert(threeCommentStr, at: index)
            addLineCount += (insertParamDocCount + 1)
        }

        if hasDoc(at: index-1, withPrefix: threeCommentStr, inLines: lines) {
            return
        }

        let funcDoc = threeCommentStr + spaceChar + descriptionStr
        lines.insert(funcDoc, at: index)

        addLineCount += 1
    }

    func insertPropertyDoc(at index: Int, withLine line: String, inLines lines: NSMutableArray) {

        let docStr = threeCommentStr + spaceChar + descriptionStr

        if hasDoc(at: index-1, withPrefix: docStr, inLines: lines) {
            return
        }

        lines.insert(docStr, at: index)
        
        addLineCount += 1

    }

    func insertFuncDoc(at index: Int, withLine line: String, inLines lines: NSMutableArray) {

        var charIndex  = line.startIndex

        while line[charIndex] == " " {
            charIndex = line.index(after: charIndex)
        }

        let spaceStr  = line.substring(to: charIndex)
        let prefixDoc = spaceStr + threeCommentStr

        if line.funcStrHasReturnValue() {

            if hasDoc(at: index-1, withPrefix: prefixDoc + returnsStr, inLines: lines) {
                return
            }

            let returnValueStr = prefixDoc + returnsStr + "<#return value description#>"

            lines.insert(returnValueStr, at: index)
            lines.insert(prefixDoc, at: index)
            addLineCount += 2
        }

        let paramNames = line.parserFuncStrParameter()
        if paramNames.count > 0 {

            for paramName in paramNames {

                if hasDoc(at: index-1, withPrefix: prefixDoc + parameterStr + paramName, inLines: lines) {
                    return
                }

                let paramDoc = prefixDoc + parameterStr + paramName + ": " + "<#\(paramName) description#>"

                lines.insert(paramDoc, at: index)

            }

            lines.insert(prefixDoc, at: index)
            addLineCount += (paramNames.count + 1)
        }

        if hasDoc(at: index-1, withPrefix: prefixDoc, inLines: lines) {
            return
        }

        let funcDoc = prefixDoc + spaceChar + descriptionStr
        lines.insert(funcDoc, at: index)

        addLineCount += 1
    }

    func insertVarOrLetDoc(at index: Int, withLine line: String, inLines lines: NSMutableArray) {

        var charIndex  = line.startIndex

        while line[charIndex] == " " {
            charIndex = line.index(after: charIndex)
        }

        let spaceStr = line.substring(to: charIndex)
        let docStr   = spaceStr + threeCommentStr + spaceChar + descriptionStr

        if hasDoc(at: index-1, withPrefix: docStr, inLines: lines) {
            return
        }

        lines.insert(docStr, at: index)

        addLineCount += 1
    }

    func hasDoc(at index: Int, withPrefix prefix: String, inLines lines: NSMutableArray) -> Bool {

        if let line = (lines[index] as? String), line.hasPrefix(prefix) {
            return true
        }

        return false
    }

}


