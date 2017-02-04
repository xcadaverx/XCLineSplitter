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
    case noParamsFound
}

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        
        let buffer = invocation.buffer
        let insertionPoint = buffer.selections[0] as? XCSourceTextRange
        
        guard let currentLine = insertionPoint?.start.line else {
            completionHandler(SplitterError.nilCurrentLine)
            return
        }
        
        guard let text = buffer.lines[currentLine] as? String else {
            completionHandler(SplitterError.nilText)
            return
        }
        
        var splittableText: String
        let prefix: String
        
        if let equalLocation = text.range(of: "=")?.upperBound {
            prefix = text.substring(to: equalLocation) + " "
            splittableText = text.substring(from: equalLocation).removeLeadingWhitespace()
        } else {
            prefix = ""
            splittableText = text
        }
        
        guard let _ = splittableText.indexDistance(of: ",") else {
            completionHandler(SplitterError.noParamsFound)
            return
        }
        
        guard let firstParenthesisLocation = splittableText.indexDistance(of: "(") else {
            completionHandler(SplitterError.noParenthesisFound)
            return
        }
        
        let prefixCount = prefix.characters.count
        let whitespace = " " * (prefixCount + firstParenthesisLocation - 1)
        let components = splittableText.components(separatedBy: ",")
        
        for (i, component) in components.enumerated() {
            if i == 0 {
                invocation.buffer.lines[currentLine] = prefix + component + ","
            } else if i == components.count - 1 {
                let line = whitespace + component
                invocation.buffer.lines.insert(line, at: currentLine + i)
            } else {
                let line = whitespace + component + ","
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
    
    func removeLeadingWhitespace() -> String {
        var copy = self
        while copy.hasPrefix(" ") {
            copy.remove(at: copy.startIndex)
        }
        return copy
    }
}

func *(lhs: String, rhs: Int) -> String {
    var string: String = ""
    for _ in 0...rhs {
        string.append(lhs)
    }
    return string
}
