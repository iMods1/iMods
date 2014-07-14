//
//  IMOPackageSignature.swift
//  iMods
//
//  Created by Brendon Roberto on 7/14/14.
//  Copyright (c) 2014 Brendon Roberto. All rights reserved.
//

// We should decide the max length of package signatures

let IMOPACKAGESIGNATURE_LENGTH = 10

typealias IMOPackageSignature = String

extension IMOPackageSignature {
    var isValid: Bool {
        get {
            var isValid = self.length == IMOPACKAGESIGNATURE_LENGTH
            return isValid
        }
    }

    var length: Int {
        get {
            return countElements(self)
        }
    }
}