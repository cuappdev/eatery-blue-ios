//
//  ReportIssueViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/27/21.
//

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

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        setUpConstraints()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
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

        view.on(UITapGestureRecognizer()) { [self] _ in
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
        cancelButton.on(UITapGestureRecognizer()) { [self] _ in
            dismiss(animated: true)
        }

        cancelButton.width(40)
        cancelButton.height(40)

        stackView.addArrangedSubview(header)
    }

    private func addTypeOfIssueButton() {
        stackView.addArrangedSubview(issueTypeButton)

        issueTypeButton.on(UITapGestureRecognizer()) { [self] _ in
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
        stackView.edges(to: view.layoutMarginsGuide)
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

    @objc private func keyboardWillChangeFrame(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }

        let keyboardFrameInViewCoordinates = view.convert(keyboardFrame, from: nil)
        let intersection = view.frame.intersection(keyboardFrameInViewCoordinates)
        additionalSafeAreaInsets.bottom = intersection.height
    }

    private func addSubmitButton() {
        stackView.addArrangedSubview(submitButton)

        submitButton.content.font = .preferredFont(for: .body, weight: .semibold)
        submitButton.content.textAlignment = .center
        submitButton.layoutMargins = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        submitButton.content.text = "Submit"

        submitButton.on(UITapGestureRecognizer()) { [self] _ in
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

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [self] in
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
