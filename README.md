# Downpour
[![license](https://img.shields.io/github/license/mashape/apistatus.svg?maxAge=2592000)](https://github.com/steve228uk/Downpour/blob/master/LICENSE) [![Build Status](https://travis-ci.org/TryFetch/Downpour.svg?branch=master)](https://travis-ci.org/TryFetch/Downpour)

Downpour was built for [Fetch](http://getfetchapp.com) — a Put.io client — to parse TV & Movie information from downloaded files. It can be used on any platform that can run Swift as it only relies on Foundation.

It can gather the following from a raw file name:

- TV or movie title
- Year of release
- TV season number
- TV episode number

## Usage

Using Downpour is easy. Just create a new instance and it'll do the rest.

```swift
let torrent = Downpour(string: filename)

let title = torrent.title
let year = torrent.year

if downpour.type == .TV {
    let season = torrent.season
    let episode = torrent.episode
}
```

## Installation

Add to your project using the Swift Package Manager by adding the following dependency to your Package.swift:
```swift
.package(url: "https://github.com/Ponyboy47/Downpour.git", .upToNextMinor(from: "0.5.0"))
```

For swift 3 use 0.4.x
