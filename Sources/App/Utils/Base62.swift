//
//  Base62.swift
//  little_link
//
//  Created by Andrew Scott on 1/19/19.
//
import Foundation

let base62Alphabet: [Character] = [
    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
    "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
    "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
    "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
]

public func encode(integer: UInt64) -> String {
    return encode(integer: integer, alphabet: base62Alphabet)
}

func encode(integer: UInt64, alphabet: [Character]) -> String {
    let base = UInt64(alphabet.count)
    
    if integer < base {
        return String(alphabet[Int(integer)])
    }
    return encode(integer: integer / base, alphabet: alphabet) + String(alphabet[Int(integer % base)])
}

public func decode(string: String) -> UInt64 {
    return decode(string: string, alphabet: base62Alphabet)
}

func decode(string: String, alphabet: [Character]) -> UInt64 {
    let base = Double(alphabet.count)
    var output: UInt64 = 0
    
    for (i, character) in string.reversed().enumerated() {
        guard let index = alphabet.index(of: character) else { continue }
        let place = UInt64(pow(base, Double(i)))
        output += UInt64(index) * place
    }
    
    return output
}
