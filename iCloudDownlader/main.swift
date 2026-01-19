//
//  main.swift
//  iCloudDownlader
//
//  Created by Lucas Tarasconi on 09/09/2018.
//  Copyright © 2018 Lucas Tarasconi. All rights reserved.
//

import Foundation
let args = Array(CommandLine.arguments.dropFirst())
let isHelpRequested = args.contains("-h") || args.contains("--help")
let isNoArgs = args.isEmpty
let showHelp = isHelpRequested || isNoArgs
let isVerbose = args.contains("-v")
let isRecursive = args.contains("-r")
let isAll = args.contains("-A")
let paths = args.filter { $0 != "-r" && $0 != "-A" && $0 != "-v" && $0 != "-h" && $0 != "--help" }

let consoleIO = ConsoleIO(isVerbose: isVerbose || showHelp)
let downloader = Downloader(consoleIO: consoleIO)

if isAll {
    consoleIO.writeMessage("Warning: -A is deprecated. Use `icd $PWD` (or `icd -r $PWD` for recursion).", to: .warning, always: true)
}

if showHelp {
    let usage = """
    Usage:
      icd <local_file_path>
      icd <local_folder_path>
      icd -r <local_folder_path>

    Options:
      -r    Recurse into subdirectories
      -v    Verbose output
      -h    Show this help
    
    Notes:
      Without -r, only files directly inside the provided folder are checked.
    """
    consoleIO.writeMessage(usage)
} else if isAll {
    downloader.downloadFolder(recursive: isRecursive)
} else if let targetPath = paths.first {
    downloader.downloadPath(targetPath, recursive: isRecursive)
} else {
    consoleIO.writeMessage("No file given. Run icd -h for help.", to: .error)
}
