//
//  SampleSelectionService.swift
//  MusicTest
//
//  Created by Oleg Shipulin on 01.11.2023.
//

import Foundation

final class SampleSelectionService {

    func getGuitars() -> [URL] {
        return [
            Bundle.main.url(forResource: "Гитара 1", withExtension: "wav"),
            Bundle.main.url(forResource: "Гитара 2", withExtension: "wav"),
            Bundle.main.url(forResource: "Гитара 3", withExtension: "wav"),
        ].compactMap { $0 }
    }

    func getWoodwinds() -> [URL] {
        return [
            Bundle.main.url(forResource: "Духовые 1", withExtension: "wav"),
            Bundle.main.url(forResource: "Духовые 2", withExtension: "wav"),
            Bundle.main.url(forResource: "Духовые 3", withExtension: "wav"),
        ].compactMap { $0 }
    }

    func getDrums() -> [URL] {
        return [
            Bundle.main.url(forResource: "Ударные 1", withExtension: "wav"),
            Bundle.main.url(forResource: "Ударные 2", withExtension: "wav"),
            Bundle.main.url(forResource: "Ударные 3", withExtension: "wav"),
        ].compactMap { $0 }
    }
}
