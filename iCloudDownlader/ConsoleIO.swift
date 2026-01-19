//
//  ConsoleIO.swift
//  iCloudDownlader
//
//  Created by Lucas Tarasconi on 09/09/2018.
//  Copyright © 2018 Lucas Tarasconi. All rights reserved.
//

import Foundation

enum OutputType {
    case error
    case standard
    case warning
}

class ConsoleIO {
    private let isVerbose: Bool
    
    init(isVerbose: Bool = false) {
        self.isVerbose = isVerbose
    }
    
    func writeMessage(_ message: String, to: OutputType = .standard, always: Bool = false) {
        if !isVerbose && to != .error && !always {
            return
        }
        switch to {
        case .standard:
            print("\(message)")
        case .warning:
            print("Warning: \(message)")
        case .error:
            fputs("Error: \(message)\n", stderr)
        }
    }
    }
