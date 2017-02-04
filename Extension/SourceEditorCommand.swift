//
//  SourceEditorCommand.swift
//  Extension
//
//  Created by Daniel Williams on 1/31/17.
//  Copyright © 2017 Daniel Williams. All rights reserved.
//

import Foundation
import XcodeKit

enum SplitterError: Error {
    case nilCurrentLine
    case nilText
    case noParenthesisFound
}

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        
        // set the buffer and point
        let buffer = invocation.buffer
        let insertionPoint = buffer.selections[0] as? XCSourceTextRange
        
        // get the current line number
        guard let currentLine = insertionPoint?.start.line else {
            completionHandler(SplitterError.nilCurrentLine)
            return
        }
        
        // get the text of the current line
        guard let text = buffer.lines[currentLine] as? String else {
            completionHandler(SplitterError.nilText)
            return
        }
        
        var splittableText: String
        let preEqualText: String
        
        if let equalLocation = text.range(of: "=")?.upperBound {
            preEqualText = text.substring(to: equalLocation) + " "
            splittableText = text.substring(from: equalLocation)
        } else {
            preEqualText = ""
            splittableText = text
        }
        
        guard let parenthesisLocation = splittableText.indexDistance(of: "(") else {
            completionHandler(SplitterError.noParenthesisFound)
            return
        }
        
        let prefixCount = preEqualText.characters.count
        
        // seperate params by ','
        let components = splittableText.components(separatedBy: ",")
        
        for (i, component) in components.enumerated() {
            if i == 0 {
                invocation.buffer.lines[currentLine] = "\(preEqualText)\(component),"
            } else if i == components.count - 1 {
                let line = " " * (parenthesisLocation + prefixCount - 1) + component
                invocation.buffer.lines.insert(line, at: currentLine + i)
            } else {
                let line = " " * (parenthesisLocation + prefixCount - 1) + component + ","
                invocation.buffer.lines.insert(line, at: currentLine + i)
            }
        }

        completionHandler(nil)

    }
    
}



extension String {
    func indexDistance(of character: Character) -> Int? {
        guard let index = characters.index(of: character) else { return nil }
        return distance(from: startIndex, to: index)
    }
}

func *(lhs: String, rhs: Int) -> String {
    var string: String = ""
    for _ in 0...rhs {
        string.append(lhs)
    }
    return string
}
