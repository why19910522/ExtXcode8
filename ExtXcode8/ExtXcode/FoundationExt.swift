//
//  FoundationExt.swift
//  ExtXcode8
//
//  Created by 王洪运 on 2016/9/28.
//  Copyright © 2016年 王洪运. All rights reserved.
//

import Foundation

extension String {

    /// 检查是否是 OC 的方法
    ///
    /// - returns: 是否是 OC 的方法
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

    /// 检查是否是 OC 的属性
    ///
    /// - returns: 是否是 OC 的属性
    func hasProperty() -> Bool {
        return contains("@property")
    }

    /// 解析 Swift 方法参数
    ///
    /// - returns: 参数名数组
    func parserFuncStrParameter() -> Array<String> {

        var arr = [String]()

        let startIdx = range(of: "(")!.upperBound
        let endIdx   = range(of: ")")!.lowerBound

        if startIdx != endIdx {
            let paramStr = substring(with: startIdx..<endIdx)

            for paramItem in paramStr.components(separatedBy: ",") {

                var paramName  = paramItem.components(separatedBy: ":").first!.trimmingCharacters(in: .whitespacesAndNewlines)

                if paramName.contains(" ") {
                    let paramNames = paramName.components(separatedBy: " ")

                    if paramNames.first!.contains("_") {
                        paramName = paramNames.last!
                    }else {
                        paramName = paramNames.first!
                    }

                }
                
                paramName = paramName.replacingOccurrences(of: ";", with: "")
                arr.append(paramName)
            }
        }

        return arr
    }

    /// 检查 Swift 是否有返回值
    ///
    /// - returns: Swift 是否有返回值
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

    /// 检查是否是 Swift 的方法
    ///
    /// - returns: 是否是 Swift 的方法
    func hasFuncMethod() -> Bool {
        return contains("func ")
    }

    /// 检查是否是 Swift 的变量或常量
    ///
    /// - returns: 是否是 Swift 的变量或常量
    func hasVarOrLet() -> Bool {
        return contains("var ") || contains("let ")
    }
    
}
