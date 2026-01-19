# iCloudDownloader

This is a simple CLI for fetching files and folders from iCloud Drive.

## Why this CLI?

Downloading a file stored on iCloud from the Finder is easy, one click and you are done. But in the terminal, you can't open a `.icloud` placeholder to force a download. **iCloudDownloader** provides a quick command to force-download iCloud files.

## Installation

* [Download the latest version](https://github.com/farnots/iCloudDownloader/releases)
* Extract the file: `tar -xf ./icd_1.0.tar`
* Move the executable to `/usr/local/bin`: `mv ./icd /usr/local/bin/icd`

## Usage

```
icd <local_file_path>
icd <local_folder_path>
icd -r <local_folder_path>
icd -A
icd -A -r
icd -h
icd -v <local_file_path>
```

Options:
- `-A` Download all items in the current folder
- `-r` Recurse into subfolders
- `-v` Verbose output
- `-h` Show help
By default, only errors are printed.

Examples:
- Download a file: `icd ~/iCloud/Notes/todo.txt`
- Download a folder recursively: `icd -r ~/iCloud/Projects`

## Compatibility

iCloudDownloader should work on macOS 10.12 Sierra and OS X 10.11 El Capitan.

## Future improvement

* Create a full iCloud manager from the terminal
    * Erase file
    * See download progression
