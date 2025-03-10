//
// This source file is part of the XCTHealthKit open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


import HealthKit
import XCTest


/// The input definition of a sample that should be added to the Health database
public struct NewHealthSampleInput {
    /// Helper type for inserting the sample's value
    public struct EnterSampleValueHandler {
        /// Signature of the actual value input function.
        public typealias Imp = @MainActor (_ sample: NewHealthSampleInput, _ healthApp: XCUIApplication) throws -> Void
        let imp: Imp
    }
    /// The quantity type for which the new sample should be added
    public let sampleType: HealthAppSampleType
    /// The date which should be used for the new sample. Specifying `nil` will use HealthKit's default date (i.e., the current date).
    public let date: DateComponents?
    /// The handler to which the actual entering of the sample value will be delegated.
    public let enterSampleValueHandler: EnterSampleValueHandler
    
    /// Creates a new health sample input, with the specified parameters
    public init(
        sampleType: HealthAppSampleType,
        date: DateComponents?,
        enterSampleValueHandler: EnterSampleValueHandler
    ) {
        self.sampleType = sampleType
        self.date = date
        self.enterSampleValueHandler = enterSampleValueHandler
    }
}


extension NewHealthSampleInput.EnterSampleValueHandler {
    /// Creates a new sample value input handler that inserts a numeric value into a text field.
    /// - parameter textFieldPredicate: optional predicate allowing the caller to specify which exact text field the value should be inserted into
    public static func enterSimpleNumericValue(_ value: Double, inTextField textFieldPredicate: NSPredicate? = nil) -> Self {
        nonisolated(unsafe) let textFieldPredicate = textFieldPredicate
        return Self { _, healthApp in
            let dataEntryTable = healthApp.tables["UIA.Health.AddData.View"]
            let textField: XCUIElement
            if let textFieldPredicate {
                textField = dataEntryTable.textFields.matching(textFieldPredicate).firstMatch
            } else {
                textField = dataEntryTable.cells["UIA.Health.AddData.ValueCell"].textFields.firstMatch
            }
            XCTAssert(textField.waitForExistence(timeout: 2))
            textField.tap()
            let stringValue: String
            if abs(value.rounded(.toNearestOrEven) - value) < 0.00001 {
                // it's essentially an int
                stringValue = String(Int(value.rounded(.toNearestOrEven)))
            } else {
                stringValue = String(format: "%.2f", locale: .current, value)
            }
            textField.typeText(stringValue)
        }
    }
    
    /// Creates a new sample value input handler that uses a custom, caller-provided closure to insert the sample's value into the Health app.
    public static func custom(_ imp: @escaping Imp) -> Self {
        Self(imp: imp)
    }
}


// MARK: Some Presets

extension NewHealthSampleInput {
    /// Creates a new Active Energy sample input, with the specified values
    public static func activeEnergy(value: Double = 52, date: DateComponents? = nil) -> Self {
        .init(sampleType: .activeEnergy, date: date, enterSampleValueHandler: .enterSimpleNumericValue(
            value,
            inTextField: NSPredicate(format: "label LIKE[cd] %@ OR label LIKE[cd] %@", "cal", "kcal")
        ))
    }
    
    /// Creates a new Resting Heart Rate sample input, with the specified values
    public static func restingHeartRate(value: Double = 87, date: DateComponents? = nil) -> Self {
        .init(sampleType: .restingHeartRate, date: date, enterSampleValueHandler: .enterSimpleNumericValue(value))
    }
    
    /// Creates a new Electrocardiogram sample input, with the specified values
    public static func electrocardiogram() -> Self {
        .init(sampleType: .electrocardiograms, date: nil, enterSampleValueHandler: .custom { _, app in
            XCTAssert(app.tables.staticTexts["High Heart Rate"].firstMatch.waitForExistence(timeout: 2))
            app.tables.staticTexts["High Heart Rate"].firstMatch.tap()
        })
    }
    
    /// Creates a new Steps sample input, with the specified values
    public static func steps(value: Double = 75, date: DateComponents? = nil) -> Self {
        .init(sampleType: .steps, date: date, enterSampleValueHandler: .enterSimpleNumericValue(value))
    }
    
    /// Creates a new Pushes sample input, with the specified values
    public static func pushes(value: Double = 85, date: DateComponents? = nil) -> Self {
        .init(sampleType: .pushes, date: date, enterSampleValueHandler: .enterSimpleNumericValue(value))
    }
}


// MARK: Data Entry


extension NewHealthSampleInput {
    /// Adds the sample to the health app.
    /// - Important: This function assumes that the Health app is already navigated to the sample type's page.
    @MainActor
    func create(in healthApp: XCUIApplication) throws {
        let navBar = healthApp.navigationBars[sampleType.healthAppDisplayTitle]
        let addDataButton = navBar.buttons["Add Data"]
        guard navBar.exists,
              navBar.buttons[sampleType.category.healthAppDisplayTitle].exists,
              addDataButton.exists else {
            throw XCTSkip("Not at the right page")
        }
        addDataButton.tap()
        
        if let date {
            XCTAssert(healthApp.staticTexts["Date"].waitForExistence(timeout: 1))
            try healthApp.enterDateComponentsInHealthAppNewSampleSheet(date, in: healthApp)
        }
        
        try enterSampleValueHandler.imp(self, healthApp)
        
        // Save the sample to the database.
        healthApp.navigationBars.firstMatch.buttons["Add"].tap()
    }
}


extension XCUIApplication {
    /// Enters date components for date and time into the "Add Sample" sheet when manually adding a sample in the Health app
    func enterDateComponentsInHealthAppNewSampleSheet(_ components: DateComponents, in app: XCUIApplication) throws {
        enterDateInHealthAppNewSampleSheet(components, in: app)
        try enterTimeInHealthAppNewSampleSheet(components, in: app)
    }
    
    
    func enterDateInHealthAppNewSampleSheet(_ components: DateComponents, in app: XCUIApplication) {
        guard components.year != nil || components.month != nil || components.day != nil else {
            // there is nothing to be done
            return
        }
        
        self.tables.staticTexts["Date"].tap() // present the data picker
        
        let monthAndYearButton = app.buttons.matching(NSPredicate(format: "label LIKE[cd] %@", "month")).firstMatch
        if !monthAndYearButton.waitForExistence(timeout: 2) {
            XCTFail("Unable to find month button")
        }
        
        guard let currentMonthAndYearSelection = monthAndYearButton.value as? String,
              let currentMonthAndYearSelection = XCUIElement.extractMonthAndYearComponents(currentMonthAndYearSelection) else {
            XCTFail("Unable to get month/year from date picker")
            self.tables.staticTexts["Date"].tap() // try to dismiss the date picker
            return
        }
        if let year = components.year, year != currentMonthAndYearSelection.year,
           let month = components.month, month != currentMonthAndYearSelection.month.value {
            monthAndYearButton.tap()
            let yearWheel = app.pickerWheels[String(currentMonthAndYearSelection.year)]
            XCTAssertTrue(yearWheel.waitForExistence(timeout: 1))
            yearWheel.adjust(toPickerWheelValue: String(year))
            let monthWheel = app.pickerWheels[String(currentMonthAndYearSelection.month.name)]
            XCTAssertTrue(monthWheel.waitForExistence(timeout: 1))
            monthWheel.adjust(toPickerWheelValue: String(XCUIElement.monthName(for: month)))
            app.buttons["DatePicker.Hide"].tap()
        } else {
            if let year = components.year, year != currentMonthAndYearSelection.year {
                monthAndYearButton.tap()
                let yearWheel = app.pickerWheels[String(currentMonthAndYearSelection.year)]
                XCTAssertTrue(yearWheel.waitForExistence(timeout: 1))
                yearWheel.adjust(toPickerWheelValue: String(year))
                app.buttons["DatePicker.Hide"].tap()
            }
            if let month = components.month {
                monthAndYearButton.tap()
                let monthWheel = app.pickerWheels[String(currentMonthAndYearSelection.month.name)]
                XCTAssertTrue(monthWheel.waitForExistence(timeout: 1))
                monthWheel.adjust(toPickerWheelValue: Self.monthName(for: month))
                app.buttons["DatePicker.Hide"].tap()
            }
        }
        if let day = components.day {
            let button = app.tables["UIA.Health.AddData.View"].cells["UIA.Health.AddData.DateCell"].staticTexts[String(day)]
            if !button.waitForExistence(timeout: 1) {
                XCTFail("Unable to find button to select day.")
            }
            button.tap()
        }
        self.tables.staticTexts["Date"].tap() // dismiss the date picker
    }
    
    
    private func enterTimeInHealthAppNewSampleSheet(_ components: DateComponents, in app: XCUIApplication) throws {
        guard components.hour != nil || components.minute != nil else {
            // there is nothing to be done
            return
        }
        self.tables.staticTexts["Time"].tap() // present the time picker
        XCTAssert(app.pickerWheels.firstMatch.waitForExistence(timeout: 1))
        let pickerWheels = app.pickers.firstMatch.pickerWheels.allElementsBoundByIndex
        if let hour = components.hour {
            if pickerWheels.count == 2 {
                // 24 hour clock
                pickerWheels[0].adjust(toPickerWheelValue: String(format: "%02lld", hour))
            } else {
                // 12 hour clock
                XCTAssertEqual(pickerWheels.count, 3)
                pickerWheels[0].adjust(toPickerWheelValue: String(hour > 12 ? hour - 12 : hour))
                let shouldLowercase = try XCTUnwrap((pickerWheels[2].value as? String)?.first).isLowercase
                pickerWheels[2].adjust(toPickerWheelValue: (hour > 12 ? "PM" : "AM").lowercased(shouldLowercase))
            }
        }
        if let minute = components.minute {
            pickerWheels[1].adjust(toPickerWheelValue: String(format: "%02lld", minute))
        }
        self.tables.staticTexts["Time"].tap() // dismiss the time picker
    }
}


extension XCUIElement {
    private static let monthAndYearFormatter = DateFormatter(format: "MMMM yyyy")
    private static let monthNames = [
        "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"
    ]
    
    static func extractMonthAndYearComponents(_ input: String) -> (month: (value: Int, name: String), year: Int)? {
        let components = input.split(separator: " ")
        let monthText = String(components[0])
        guard let monthValue = Self.monthValue(for: monthText),
              let year = Int(components[1]) else {
            return nil
        }
        return (month: (value: monthValue + 1, name: monthText), year: year)
    }
    
    static func monthName(for value: Int) -> String {
        monthNames[value - 1]
    }
    
    /// returns the **numeric** value of the month, i.e., 1 for january, 2 for february, and so on
    static func monthValue(for name: String) -> Int? {
        monthNames.firstIndex(where: { $0.localizedCompare(name) == .orderedSame })
    }
}


extension DateFormatter {
    convenience init(format: String) {
        self.init()
        self.dateFormat = format
    }
}


extension String {
    func lowercased(_ isLower: Bool) -> String {
        isLower ? self.lowercased() : self
    }
}
