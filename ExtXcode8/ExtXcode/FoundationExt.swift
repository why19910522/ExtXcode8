//
//  FoundationExt.swift
//  ExtXcode8
//
//  Created by 王洪运 on 2016/9/28.
//  Copyright © 2016年 王洪运. All rights reserved.
//

import Foundation

extension String {

    func hasMethod() -> Bool {
        let str     = replacingOccurrences(of: " ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        let pattern = "[-,+]\\(\\S*\\).*\\{"
        let regular = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)

        let results = regular.matches(in: str, options: .reportProgress, range: NSMakeRange(0, str.characters.count))

        if results.count == 1 {

            if let range = results.first?.range, range.location == 0, range.length == str.characters.count {
                return true
            }
        }

        return false
    }

    func hasProperty() -> Bool {
        return contains("@property")
    }

    func parserFuncStrParameter() -> Array<String> {

        var arr: Array<String> = Array()

        let startIdx = range(of: "(")!.upperBound
        let endIdx   = range(of: ")")!.lowerBound

        if startIdx != endIdx {
            let paramStr = substring(with: startIdx..<endIdx)

            for var paramItem in paramStr.components(separatedBy: ",") {

                paramItem     = paramItem.replacingOccurrences(of: " ", with: "")
                var paramName = paramItem.components(separatedBy: ":").first!
                paramName     = paramName.replacingOccurrences(of: "_", with: "")
                arr.append(paramName)
            }
        }

        return arr
    }

    func funcStrHasReturnValue() -> Bool {

        let tempIndex     = range(of: ")")!.lowerBound
        let returnTypeStr = substring(from: tempIndex).replacingOccurrences(of: " ", with: "")

        if returnTypeStr.contains("->Void") {
            return false
        } else if returnTypeStr.contains("->") {
            return true
        }else {
            return false
        }
    }

    func hasFuncMethod() -> Bool {
        return contains("func ")
    }
    
    func hasVarOrLet() -> Bool {
        return contains("var ") || contains("let ")
    }
    
}
