//
//  HelperClass.swift
//  ImageFeed
//
//  Created by Kalaiprabha L on 24/06/22.
//

import Foundation

class HelperClass {
    class func readLocalFile(forName name: String) -> Data? {
        do {
            if let bundlePath = Bundle.main.path(forResource: name,
                                                 ofType: "json"),
               let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                return jsonData
            }
        } catch {
            print(error)
        }
        
        return nil
    }
}
