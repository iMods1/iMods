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
    var imo_IsValid: Bool {
        get {
            var isValid = self.imo_Length == IMOPACKAGESIGNATURE_LENGTH
            return isValid
        }
    }

    var imo_Length: Int {
        get {
            return countElements(self)
        }
    }
}
