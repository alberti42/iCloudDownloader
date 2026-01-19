//
//  Downloader.swift
//  iCloudDownlader
//
//  Created by Lucas Tarasconi on 09/09/2018.
//  Copyright © 2018 Lucas Tarasconi. All rights reserved.
//

import Foundation

let fm = FileManager.default
let path = fm.currentDirectoryPath

class Downloader {
    let consoleIO: ConsoleIO
    
    init(consoleIO: ConsoleIO) {
        self.consoleIO = consoleIO
    }
    
    private func isDirectory(_ url: URL) -> Bool {
        var isDir: ObjCBool = false
        if fm.fileExists(atPath: url.path, isDirectory: &isDir) {
            return isDir.boolValue
        }
        return false
    }
    
    private func isExcludedFromSync(_ url: URL) -> Bool {
        if #available(macOS 11.3, *) {
            do {
                let values = try url.resourceValues(forKeys: [.ubiquitousItemIsExcludedFromSyncKey])
                return values.ubiquitousItemIsExcludedFromSync ?? false
            } catch {
                consoleIO.writeMessage("Can't get attributes for \(fm.displayName(atPath: url.lastPathComponent)): \(error)", to: .error)
                return false
            }
        }
        return false
    }
    
    private func downloadDirectory(at directoryUrl: URL, recursive: Bool) {
        do {
            if isExcludedFromSync(directoryUrl) {
                consoleIO.writeMessage("\(fm.displayName(atPath: directoryUrl.lastPathComponent)) is excluded from iCloud sync", to: .warning)
                return
            }
            if recursive {
                var directoryKeys: [URLResourceKey] = [.isDirectoryKey]
                if #available(macOS 11.3, *) {
                    directoryKeys.append(.ubiquitousItemIsExcludedFromSyncKey)
                }
                let enumerator = fm.enumerator(at: directoryUrl,
                                               includingPropertiesForKeys: directoryKeys,
                                               options: [],
                                               errorHandler: { url, error in
                                                   self.consoleIO.writeMessage("Can't access \(url.path): \(error)", to: .error)
                                                   return true
                                               })
                
                guard let enumerator = enumerator else {
                    consoleIO.writeMessage("Can't access the folder", to: .error)
                    return
                }
                
                for case let itemUrl as URL in enumerator {
                    if isDirectory(itemUrl) {
                        if isExcludedFromSync(itemUrl) {
                            enumerator.skipDescendants()
                        }
                        continue
                    }
                    if isExcludedFromSync(itemUrl) {
                        continue
                    }
                    fetchFile(fileUrl: itemUrl)
                }
            } else {
                var directoryKeys: [URLResourceKey] = [.isDirectoryKey]
                if #available(macOS 11.3, *) {
                    directoryKeys.append(.ubiquitousItemIsExcludedFromSyncKey)
                }
                let items = try fm.contentsOfDirectory(at: directoryUrl,
                                                       includingPropertiesForKeys: directoryKeys,
                                                       options: [])
                
                for itemUrl in items {
                    if isDirectory(itemUrl) {
                        continue
                    }
                    if isExcludedFromSync(itemUrl) {
                        continue
                    }
                    fetchFile(fileUrl: itemUrl)
                }
            }
        } catch {
            consoleIO.writeMessage("Can't access the folder: \(error)", to: .error)
        }
    }
    
    func fetchFile(fileUrl : URL) {
        let status: URLResourceValues;
        
        do {
            var keys: Set<URLResourceKey> = [.isUbiquitousItemKey,
                                             .ubiquitousItemIsDownloadingKey,
                                             .ubiquitousItemDownloadingStatusKey]
            if #available(macOS 11.3, *) {
                keys.insert(.ubiquitousItemIsExcludedFromSyncKey)
            }
            status = try fileUrl.resourceValues(forKeys: keys)
        } catch {
            consoleIO.writeMessage("Can't get attributes for file \(fm.displayName(atPath: fileUrl.lastPathComponent)): \(error)", to: .error)
            return
        }
        
        if status.isUbiquitousItem ?? false {
            if #available(macOS 11.3, *) {
                if status.ubiquitousItemIsExcludedFromSync ?? false {
                    consoleIO.writeMessage("\(fm.displayName(atPath: fileUrl.lastPathComponent)) is excluded from iCloud sync", to: .warning)
                    return
                }
            }
            if status.ubiquitousItemDownloadingStatus == .current {
                consoleIO.writeMessage("\(fm.displayName(atPath: fileUrl.lastPathComponent)) is already downloaded", to: .warning)
            } else if status.ubiquitousItemIsDownloading ?? false {
                consoleIO.writeMessage("\(fm.displayName(atPath: fileUrl.lastPathComponent)) is downloading")
            } else {
                do {
                    try fm.startDownloadingUbiquitousItem(at: fileUrl)
                    consoleIO.writeMessage("Info: \(fileUrl.lastPathComponent) is downloading")
                } catch {
                    consoleIO.writeMessage("Can't download \(fm.displayName(atPath: fileUrl.lastPathComponent)): \(error)", to: .error)
                }
            }
        } else {
            consoleIO.writeMessage("\(fm.displayName(atPath: fileUrl.lastPathComponent)) is not an iCloud file", to: .warning)
        }
    }
    
    func downloadPath(_ path: String, recursive: Bool) {
        let fileUrl = NSURL.fileURL(withPath: path)
        if isDirectory(fileUrl) {
            downloadDirectory(at: fileUrl, recursive: recursive)
        } else {
            fetchFile(fileUrl: fileUrl)
        }
    }
    
    func downloadFolder(recursive: Bool) {
        let folderUrl = NSURL.fileURL(withPath: path)
        downloadDirectory(at: folderUrl, recursive: recursive)
    }
    
    
    
    
}
