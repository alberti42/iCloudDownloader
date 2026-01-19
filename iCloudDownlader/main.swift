//
//  main.swift
//  iCloudDownlader
//
//  Created by Lucas Tarasconi on 09/09/2018.
//  Copyright © 2018 Lucas Tarasconi. All rights reserved.
//

import Foundation
let args = Array(CommandLine.arguments.dropFirst())
let showHelp = args.contains("-h") || args.contains("--help")
let isVerbose = args.contains("-v")
let isRecursive = args.contains("-r")
let isAll = args.contains("-A")
let paths = args.filter { $0 != "-r" && $0 != "-A" && $0 != "-v" && $0 != "-h" && $0 != "--help" }

let consoleIO = ConsoleIO(isVerbose: isVerbose || showHelp)
let downloader = Downloader(consoleIO: consoleIO)

if showHelp {
    let usage = """
    Usage:
      icd <local_file_path>
      icd <local_folder_path>
      icd -r <local_folder_path>
      icd -A
      icd -A -r

    Options:
      -A    Download all items in current folder
      -r    Recurse into subfolders
      -v    Verbose output
      -h    Show this help
    """
    consoleIO.writeMessage(usage)
} else if isAll {
    downloader.downloadFolder(recursive: isRecursive)
} else if let targetPath = paths.first {
    downloader.downloadPath(targetPath, recursive: isRecursive)
} else {
    consoleIO.writeMessage("No file given", to: .error)
}
