//
//  AppConfigTests.swift
//  OBAKitTests
//
//  Created by Aaron Brethorst on 11/23/18.
//  Copyright © 2018 OneBusAway. All rights reserved.
//

import UIKit

import Foundation
import XCTest
@testable import OBAKit
import CoreLocation
import Nimble

class AppConfigTests: OBATestCase {
    let regionsBaseURL = URL(string: "http://www.example.com")!
    let apiKey = "apikey"
    let uuid = "uuid-string"
    let appVersion = "app-version"
    var userDefaults: UserDefaults!

    override func setUp() {
        super.setUp()

        userDefaults = UserDefaults(suiteName: "apptests")
    }

    override func tearDown() {
        super.tearDown()

        userDefaults.removeSuite(named: "apptests")
    }

    func testAppConfig_creation_propertiesWork() {
        let queue = OperationQueue()

        let locationManager = AuthorizedMockLocationManager(updateLocation: TestData.mockSeattleLocation, updateHeading: TestData.mockHeading)
        let locationService = LocationService(locationManager: locationManager)
        let appConfig = AppConfig(regionsBaseURL: regionsBaseURL, apiKey: apiKey, uuid: uuid, appVersion: appVersion, userDefaults: userDefaults, queue: queue, locationService: locationService)

        expect(appConfig.regionsBaseURL) == regionsBaseURL
        expect(appConfig.apiKey) == apiKey
        expect(appConfig.uuid) == uuid
        expect(appConfig.appVersion) == appVersion
        expect(appConfig.queue) == queue
        expect(appConfig.userDefaults) == userDefaults

        expect(appConfig.regionsService).toNot(beNil())
    }
}