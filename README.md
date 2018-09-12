# Downpour
[![license](https://img.shields.io/badge/license-GPLv3-blue.svg)](https://github.com/Ponyboy47/Downpour/blob/master/LICENSE) [![Build Status](https://travis-ci.org/Ponyboy47/Downpour.svg?branch=master)](https://travis-ci.org/Ponyboy47/Downpour)

Downpour was built for [Fetch](http://getfetchapp.com) — a Put.io client — to parse TV & Movie information from downloaded files. It can be used on any platform that can run Swift as it only relies on Foundation.

It can gather the following from a raw video file name:

- TV or movie title
- Year of release
- TV season number
- TV episode number

It can gather the following from an audio file on macOS:

- Title
- Creation Date
- Type
- Format
- Copyrights
- Album
- Artist
- Artwork
- Publisher
- Creator
- Subject
- Summary (AKA Description)
- Contributer
- Last Modified Date
- Language
- Author

And from Linux (Ubuntu if the libimage-exiftool-perl package is installed):

- Title
- Creation Date
- Type
- Format
- Copyrights
- Album
- Artist
- Artwork

NOTE: None of the fields are guaranteed to be there or even picked up, it's kinda hard to extract metadata from file names with only a few clever regexes and audio data from files is difficult to do cross-platform. Please open an issue if you know the data is there, but it's not being picked up. Also, it means everything is Optional and be sure to use `guard/if let` or nil-coalescing (`??`) to program safely. :)

## Installation
### Swift Package Manager:
This supports SPM installation for swift 4.2+ by adding the following to your Package.swift dependencies:
```swift
.package(url: "https://github.com/Ponyboy47/Downpour.git", from: "0.7.0")
```
For swift 4.0 or 4.1 use 0.6.x
For swift 3 use 0.4.x

## Usage

Using Downpour is easy. Just create a new instance and it'll do the rest.

```swift
let dvd_rip = Downpour(filename: filename)

let title = dvd_rip.title
let year = dvd_rip.year

if downpour.type == .tv {
    let season = dvd_rip.season
    let episode = dvd_rip.episode
}
```

### Common Scenarios:
- Backing up your dvd/blu-ray collection
  - Designed to work with media ripped using the popular [MakeMKV](http://makemkv.com) utility
- Organizing your media files

