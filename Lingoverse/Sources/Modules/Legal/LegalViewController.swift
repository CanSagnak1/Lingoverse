//
//  LegalViewController.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 1.01.2026.
//

import UIKit

final class LegalViewController: UIViewController {

    private let documentType: LegalDocumentType

    private lazy var textView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isEditable = false
        tv.font = .systemFont(ofSize: 15)
        tv.textColor = DSColor.textPrimary
        tv.backgroundColor = .systemBackground
        tv.textContainerInset = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
        tv.showsVerticalScrollIndicator = true
        return tv
    }()

    init(documentType: LegalDocumentType) {
        self.documentType = documentType
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError(Cammon.fatalError)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadContent()
    }

    private func setupUI() {
        title = documentType.rawValue
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never

        view.addSubview(textView)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func loadContent() {
        let content = LegalContent.content(for: documentType)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        paragraphStyle.paragraphSpacing = 12

        let attributedString = NSMutableAttributedString(
            string: content,
            attributes: [
                .font: UIFont.systemFont(ofSize: 15),
                .foregroundColor: DSColor.textPrimary,
                .paragraphStyle: paragraphStyle,
            ]
        )

        // Style headings
        let headingPatterns = [
            "PRIVACY POLICY",
            "TERMS OF USE",
            "ACKNOWLEDGEMENTS",
            "1. ", "2. ", "3. ", "4. ", "5. ", "6. ", "7. ", "8. ", "9. ", "10. ", "11. ",
        ]

        for pattern in headingPatterns {
            let range = (content as NSString).range(of: pattern)
            if range.location != NSNotFound {
                if pattern.count <= 4 {
                    // Numbered headings - find the full line
                    let lineEnd = (content as NSString).range(
                        of: "\n", options: [],
                        range: NSRange(
                            location: range.location, length: content.count - range.location))
                    let fullRange = NSRange(
                        location: range.location,
                        length: (lineEnd.location != NSNotFound ? lineEnd.location : content.count)
                            - range.location)
                    attributedString.addAttribute(
                        .font, value: UIFont.boldSystemFont(ofSize: 16), range: fullRange)
                } else {
                    // Main title
                    attributedString.addAttribute(
                        .font, value: UIFont.boldSystemFont(ofSize: 22), range: range)
                    attributedString.addAttribute(
                        .foregroundColor, value: DSColor.accent, range: range)
                }
            }
        }

        // Style section headers in acknowledgements
        let sectionHeaders = [
            "FREE DICTIONARY API",
            "SF SYMBOLS",
            "OPEN SOURCE COMMUNITY",
            "SPECIAL THANKS",
        ]

        for header in sectionHeaders {
            let range = (content as NSString).range(of: header)
            if range.location != NSNotFound {
                attributedString.addAttribute(
                    .font, value: UIFont.boldSystemFont(ofSize: 17), range: range)
                attributedString.addAttribute(.foregroundColor, value: DSColor.accent, range: range)
            }
        }

        textView.attributedText = attributedString
        textView.setContentOffset(.zero, animated: false)
    }
}
