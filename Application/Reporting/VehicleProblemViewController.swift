//
//  VehicleProblemViewController.swift
//  OBAKit
//
//  Created by Aaron Brethorst on 6/16/19.
//

import UIKit
import Eureka
import SVProgressHUD
import OBAKitCore

// TODO: this seems...busted. I can't figure out when this
// initializer will actually be called, though. Do I even
// really need it?
extension TripProblemCode: InputTypeInitiable {
    public init?(string stringValue: String) {
        return nil
    }
}

class VehicleProblemViewController: FormViewController {
    // MARK: - Properties
    private let application: Application
    private let arrivalDeparture: ArrivalDeparture

    // MARK: - Form Rows

    private lazy var problemCodePicker: PickerInputRow<TripProblemCode> = {
        return PickerInputRow<TripProblemCode> {
            $0.title = NSLocalizedString("vehicle_problem_controller.problem_section.row_label", value: "Pick one:", comment: "Title label for the 'choose a problem type' row.")
            $0.options = TripProblemCode.allCases
            $0.value = $0.options.first
            $0.displayValueFor = { code -> String? in
                guard let code = code else { return nil }
                return tripProblemCodeToUserFacingString(code)
            }
        }
    }()

    private lazy var onVehicleSwitch = SwitchRow {
        $0.title = NSLocalizedString("vehicle_problem_controller.on_vehicle_section.switch_title", value: "On the vehicle", comment: "Title of the 'on the vehicle' switch in the Vehicle Problem Controller.")
    }

    private lazy var vehicleIDField = TextRow {
        $0.title = NSLocalizedString("vehicle_problem_controller.on_vehicle_section.vehicle_id_title", value: "Vehicle ID", comment: "Title of the vehicle ID text field in the Vehicle Problem Controller.")

        $0.value = arrivalDeparture.vehicleID
    }

    private lazy var commentsField = TextAreaRow()

    // MARK: - Init

    init(application: Application, arrivalDeparture: ArrivalDeparture) {
        self.application = application
        self.arrivalDeparture = arrivalDeparture

        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("vehicle_problem_controller.title", value: "Report a Problem", comment: "Title for the Report Vehicle Problem controller")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        let commentsRow = TextAreaRow()

        form

        // Trip Problem Code
        +++ Section(NSLocalizedString("vehicle_problem_controller.problem_section.section_title", value: "What seems to be the problem?", comment: "Title of the first section in the Vehicle Problem Controller."))
        <<< problemCodePicker

        // On the Vehicle
        +++ Section(NSLocalizedString("vehicle_problem_controller.on_vehicle_section.section_title", value: "Are you on this vehicle?", comment: "Title of the 'on the vehicle' section in the Vehicle Problem Controller."))
        <<< onVehicleSwitch
        <<< vehicleIDField

        // Comments Section
        +++ Section(NSLocalizedString("vehicle_problem_controller.comments_section.section_title", value: "Additional comments (optional)", comment: "The section header to a free-form comments field that the user does not have to add text to in order to submit this form."))
        <<< commentsRow

            // Button Section
        +++ Section()
        <<< ButtonRow {
            $0.title = NSLocalizedString("vehicle_problem_controller.send_button", value: "Send Message", comment: "The 'send' button that actually sends along the problem report.")
            $0.onCellSelection { [weak self] (_, _) in
                guard let self = self else { return }
                self.submitForm()
            }
        }
    }

    private func submitForm() {
        guard
            let modelService = application.restAPIModelService,
            let tripProblemCode = problemCodePicker.value,
            let onVehicle = onVehicleSwitch.value
        else { return }

        let location = application.locationService.currentLocation

        let op = modelService.getTripProblem(
            tripID: arrivalDeparture.tripID,
            serviceDate: arrivalDeparture.serviceDate,
            vehicleID: vehicleIDField.value,
            stopID: arrivalDeparture.stopID,
            code: tripProblemCode,
            comment: commentsField.value,
            userOnVehicle: onVehicle,
            location: location
        )

        SVProgressHUD.show()

        op.then { [weak self] in
            guard let self = self else { return }

            if let error = op.error {
                AlertPresenter.show(error: error, presentingController: self)
                SVProgressHUD.dismiss()
            }
            else {
                SVProgressHUD.showSuccessAndDismiss()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
