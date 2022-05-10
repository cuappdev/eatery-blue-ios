//
//  ReportIssueViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/27/21.
//

import EateryModel
import UIKit

class ReportIssueViewController: UIViewController {

    enum IssueType: CustomStringConvertible, CaseIterable {

        case inaccurateItem
        case differentPrice
        case incorrectHours
        case inaccurateWaitTime
        case inaccurateDescription
        case other

        var description: String {
            switch self {
            case .inaccurateItem: return "Inaccurate or missing item"
            case .differentPrice: return "Different price than listed"
            case .incorrectHours: return "Incorrect hours"
            case .inaccurateWaitTime: return "Inaccurate wait times"
            case .inaccurateDescription: return "Inaccurate description"
            case .other: return "Other"
            }
        }

    }

    private let stackView = UIStackView()
    private let issueTypeButton = IssueTypeButtonView()
    private let issueDescriptionView = IssueDescriptionView()
    private let submitButton = ContainerView(pillContent: UILabel())

    private(set) var selectedIssueType: IssueType?

    private var isSubmitting: Bool = false
    private var submitEnabled: Bool {
        !isSubmitting && selectedIssueType != nil && !issueDescriptionView.textView.text.isEmpty
    }

    private var eateryId: Int64?

    init(eateryId: Int64? = nil) {
        self.eateryId = eateryId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        setUpConstraints()
    }

    private func setUpView() {
        view.layoutMargins = UIEdgeInsets(
            top: 16,
            left: 16,
            bottom: 16,
            right: 16
        )
        view.backgroundColor = .white

        view.addSubview(stackView)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 12

        addHeaderView()
        addHeader(title: "Type of issue")
        addTypeOfIssueButton()
        addHeader(title: "Description")
        addIssueDescriptionView()
        addSubmitButton()

        view.tap { [self] _ in
            issueDescriptionView.textView.resignFirstResponder()
        }
    }

    private func addHeaderView() {
        let header = UIStackView()
        header.axis = .horizontal

        let titleLabel = UILabel()
        header.addArrangedSubview(titleLabel)
        titleLabel.font = .preferredFont(for: .title2, weight: .semibold)
        titleLabel.textColor = UIColor(named: "Black")
        titleLabel.text = "Report an issue"

        let cancelButton = UIImageView()
        cancelButton.isUserInteractionEnabled = true
        header.addArrangedSubview(cancelButton)
        cancelButton.image = UIImage(named: "ButtonClose")
        cancelButton.tap { [self] _ in
            dismiss(animated: true)
        }

        cancelButton.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }

        stackView.addArrangedSubview(header)
    }

    private func addTypeOfIssueButton() {
        stackView.addArrangedSubview(issueTypeButton)

        issueTypeButton.tap { [self] _ in
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            for choice in IssueType.allCases {
                alertController.addAction(UIAlertAction(title: choice.description, style: .default) { [self] _ in
                    selectedIssueType = choice
                    updateIssueTypeButtonFromState()
                    updateSubmitButtonFromState()
                })
            }
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alertController, animated: true)
        }

        updateIssueTypeButtonFromState()
    }

    private func addHeader(title: String) {
        let label = UILabel()
        label.font = .preferredFont(for: .subheadline, weight: .semibold)
        label.textColor = UIColor(named: "Black")
        label.text = title
        stackView.addArrangedSubview(label)
    }

    private func addIssueDescriptionView() {
        stackView.addArrangedSubview(issueDescriptionView)
        issueDescriptionView.textView.delegate = self
    }

    private func setUpConstraints() {
        stackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.layoutMarginsGuide)

            make.bottom.equalTo(view.layoutMarginsGuide).priority(.high)
            make.bottom.lessThanOrEqualTo(view.layoutMarginsGuide)

            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-16).priority(.high)

            // This constraint is *not* required because otherwise it would trigger an unsatisfiable constraints
            // exception when the view was dismissed
            make.bottom.lessThanOrEqualTo(view.keyboardLayoutGuide.snp.top).offset(-16).priority(.required.advanced(by: -1))
        }
    }

    private func updateIssueTypeButtonFromState() {
        if let selectedIssueType = selectedIssueType {
            issueTypeButton.label.text = selectedIssueType.description
            issueTypeButton.label.textColor = UIColor(named: "Black")
            issueTypeButton.label.font = .preferredFont(for: .subheadline, weight: .medium)

        } else {
            issueTypeButton.label.text = "Choose an option..."
            issueTypeButton.label.textColor = UIColor(named: "Gray05")
            issueTypeButton.label.font = .preferredFont(for: .subheadline, weight: .medium)
        }
    }

    private func addSubmitButton() {
        stackView.addArrangedSubview(submitButton)

        submitButton.content.font = .preferredFont(for: .body, weight: .semibold)
        submitButton.content.textAlignment = .center
        submitButton.layoutMargins = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        submitButton.content.text = "Submit"

        submitButton.tap { [self] _ in
            if submitEnabled {
                submit()
            }
        }

        updateSubmitButtonFromState()
    }

    private func updateSubmitButtonFromState() {
        if submitEnabled {
            submitButton.cornerRadiusView.backgroundColor = UIColor(named: "EateryBlue")
            submitButton.content.textColor = .white
        } else {
            submitButton.cornerRadiusView.backgroundColor = UIColor(named: "Gray00")
            submitButton.content.textColor = UIColor(named: "Gray03")
        }
    }

    private func submit() {
        isSubmitting = true
        updateSubmitButtonFromState()
        view.isUserInteractionEnabled = false
        view.endEditing(true)

        Task {
            await EateryAPI(url: URL(string: "https://eatery-dev.cornellappdev.com/api/report")!)
                .reportError(
                    eateryId: self.eateryId,
                    type: selectedIssueType?.description ?? "Other",
                    content: issueDescriptionView.textView.text
                )
            dismiss(animated: true)
        }
    }

    func setSelectedIssueType(_ issueType: IssueType) {
        selectedIssueType = issueType
    }

}

extension ReportIssueViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        issueDescriptionView.placeholderLabel.isHidden = true
    }

    func textViewDidChange(_ textView: UITextView) {
        updateSubmitButtonFromState()
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        } else {
            return true
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            issueDescriptionView.placeholderLabel.isHidden = false
        }
    }

}
