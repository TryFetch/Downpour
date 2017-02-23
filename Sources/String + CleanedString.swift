//
//  String + CleanedString.swift
//  Downpour
//
//  Created by Stephen Radford on 18/05/2016.
//  Copyright © 2015 Stephen Radford. All rights reserved.
//

import Foundation

extension String {

    var cleanedString: String {
        var cleaned = self
        cleaned = cleaned.trimmingCharacters(in: CharacterSet(charactersIn: " -.([]{}))"))
        cleaned = cleaned.replacingOccurrences(of: ".", with: " ")
        return cleaned
    }

}
