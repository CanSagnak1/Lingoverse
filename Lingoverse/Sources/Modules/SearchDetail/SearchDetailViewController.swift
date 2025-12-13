//
//  SearchDetailViewController.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 2.11.2025.
//

import UIKit
import AVFoundation

protocol SearchDetailViewInput: AnyObject {
    func render(_ state: SearchDetailState)
}

final class SearchDetailViewController: UIViewController, SearchDetailViewInput {
    
    var presenter: SearchDetailViewOutput!
    private var allMeanings: [SearchDetailMeaningVM] = []
    private var player: AVPlayer?
    private var audioURL: URL?
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = DSSpacing.x6
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = DSTypo.largeTitle
        label.textColor = DSColor.textPrimary
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var phoneticLabel: UILabel = {
        let label = UILabel()
        label.font = DSTypo.title2
        label.textColor = DSColor.textSecondary
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var audioButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "waveform.circle.fill"), for: .normal)
        button.tintColor = DSColor.accent
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.isHidden = true
        button.addTarget(self, action: #selector(didTapAudio), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 35),
            button.heightAnchor.constraint(equalToConstant: 35)
        ])
        return button
    }()
    
    private lazy var segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl()
        sc.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        sc.isHidden = true
        return sc
    }()
    
    private lazy var meaningsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = DSSpacing.x4
        return stackView
    }()
    
    private lazy var loadingView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var errorView: DSErrorView = {
        let errorView = DSErrorView()
        errorView.translatesAutoresizingMaskIntoConstraints = false
        errorView.isHidden = true
        return errorView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.viewDidLoad()
    }
        
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        
        view.addSubview(scrollView)
        scrollView.addSubview(mainStackView)
        
        let headerStack = UIStackView(arrangedSubviews: [titleLabel, phoneticLabel])
        headerStack.axis = .vertical
        headerStack.spacing = DSSpacing.x1
        
        let titleRowStack = UIStackView(arrangedSubviews: [headerStack, audioButton])
        titleRowStack.axis = .horizontal
        titleRowStack.alignment = .center
        titleRowStack.distribution = .fill
        
        mainStackView.addArrangedSubview(titleRowStack)
        mainStackView.addArrangedSubview(segmentedControl)
        mainStackView.addArrangedSubview(meaningsStackView)
        
        setupStatusViews()
        
        let contentLayout = scrollView.contentLayoutGuide
        let frameLayout = scrollView.frameLayoutGuide
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            mainStackView.topAnchor.constraint(equalTo: contentLayout.topAnchor, constant: DSSpacing.x4),
            mainStackView.bottomAnchor.constraint(equalTo: contentLayout.bottomAnchor, constant: -DSSpacing.x8),
            mainStackView.leadingAnchor.constraint(equalTo: frameLayout.leadingAnchor, constant: DSSpacing.x4),
            mainStackView.trailingAnchor.constraint(equalTo: frameLayout.trailingAnchor, constant: -DSSpacing.x4)
        ])
    }
    
    private func setupStatusViews() {
        view.addSubview(loadingView)
        view.addSubview(errorView)
        errorView.onRetry = { [weak self] in
            self?.presenter.viewDidLoad()
        }
        
        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            errorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: DSSpacing.x4),
            errorView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -DSSpacing.x4)
        ])
    }
    
    func render(_ state: SearchDetailState) {
        loadingView.stopAnimating()
        errorView.isHidden = true
        mainStackView.isHidden = true
        
        switch state {
        case .loading:
            loadingView.startAnimating()
            
        case .content(let header, let segments, let meanings):
            mainStackView.isHidden = false
            allMeanings = meanings
            
            titleLabel.text = header.title
            phoneticLabel.text = header.phonetic
            phoneticLabel.isHidden = (header.phonetic == nil)
            audioButton.isHidden = (header.audioURL == nil)
            self.audioURL = header.audioURL
            
            segmentedControl.removeAllSegments()
            for (index, title) in segments.titles.enumerated() {
                segmentedControl.insertSegment(withTitle: title, at: index, animated: false)
            }
            segmentedControl.isHidden = (segments.titles.count <= 1)
            if segmentedControl.numberOfSegments > 0 {
                segmentedControl.selectedSegmentIndex = 0
            }

            drawMeanings(for: 0)
            
        case .error(let message):
            errorView.isHidden = false
            errorView.configure(message: message)
        }
    }
    
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        drawMeanings(for: sender.selectedSegmentIndex)
    }
    
    @objc private func didTapAudio() {
        guard let audioURL = self.audioURL else { return }
        player = AVPlayer(url: audioURL)
        player?.play()
    }

    private func drawMeanings(for index: Int) {
        meaningsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        guard index < allMeanings.count else { return }
        let selectedMeaning = allMeanings[index]
        
        for (defIndex, definitionVM) in selectedMeaning.definitions.enumerated() {
            let definitionView = DefinitionView()
            definitionView.configure(with: definitionVM, index: defIndex + 1)
            meaningsStackView.addArrangedSubview(definitionView)
            
            if defIndex < selectedMeaning.definitions.count - 1 {
                meaningsStackView.addArrangedSubview(createDivider())
            }
        }
        
        if let synonyms = selectedMeaning.synonyms, !synonyms.isEmpty {
            meaningsStackView.setCustomSpacing(DSSpacing.x6, after: meaningsStackView.arrangedSubviews.last!)
            meaningsStackView.addArrangedSubview(createSynonymsSection(for: synonyms))
        }
    }
    
    private func createDivider() -> UIView {
        let divider = UIView()
        divider.backgroundColor = DSColor.surface
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        divider.alpha = 0.5
        return divider
    }
    
    private func createDefinitionView(for vm: SearchDetailDefinitionVM, index: Int) -> UIView {
        let definitionView = DefinitionView()
        definitionView.configure(with: vm, index: index)
        return definitionView
    }
    
    private func createSynonymsSection(for synonyms: [String]) -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = DSSpacing.x2
        stack.alignment = .leading
        
        let titleLabel = UILabel()
        titleLabel.text = Strings.synonymsText
        titleLabel.font = DSTypo.title2
        titleLabel.textColor = DSColor.textSecondary
        
        stack.addArrangedSubview(titleLabel)
        
        let pillContainer = SynonymPillContainerView()
        pillContainer.synonyms = synonyms
        stack.addArrangedSubview(pillContainer)
        pillContainer.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
        
        return stack
    }
}

private final class DefinitionView: UIView {
    
    private lazy var definitionLabel: UILabel = {
        let label = UILabel()
        label.font = DSTypo.body
        label.textColor = DSColor.textPrimary
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var exampleLabel: UILabel = {
        let label = UILabel()
        label.font = DSTypo.footnote
        label.textColor = DSColor.textSecondary
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    private lazy var exampleContainer: UIView = {
        let view = UIView()
        view.isHidden = true
        
        let quoteLine = UIView()
        quoteLine.backgroundColor = DSColor.accent
        quoteLine.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(quoteLine)
        view.addSubview(exampleLabel)
        exampleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            quoteLine.topAnchor.constraint(equalTo: view.topAnchor),
            quoteLine.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            quoteLine.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            quoteLine.widthAnchor.constraint(equalToConstant: 2),
            
            exampleLabel.topAnchor.constraint(equalTo: view.topAnchor),
            exampleLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            exampleLabel.leadingAnchor.constraint(equalTo: quoteLine.trailingAnchor, constant: DSSpacing.x2),
            exampleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        return view
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [definitionLabel, exampleContainer])
        stack.axis = .vertical
        stack.spacing = DSSpacing.x2
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mainStackView)
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor, constant: DSSpacing.x2),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -DSSpacing.x2),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError(Cammon.fatalError)
    }
    
    func configure(with vm: SearchDetailDefinitionVM, index: Int) {
        definitionLabel.text = "\(vm.definition)"
        
        if let example = vm.example, !example.isEmpty {
            exampleLabel.text = "\"\(example)\""
            exampleLabel.isHidden = false
            exampleContainer.isHidden = false
        }
    }
}

private final class SynonymPillButton: UIButton {
    
    init(title: String) {
        super.init(frame: .zero)
        let padding = UIEdgeInsets(top: DSSpacing.x1, left: DSSpacing.x2, bottom: DSSpacing.x1, right: DSSpacing.x2)
        if #available(iOS 15.0, *) {
            var cfg = UIButton.Configuration.filled()
            cfg.baseBackgroundColor = DSColor.surface
            cfg.baseForegroundColor = DSColor.accent
            cfg.cornerStyle = .medium
            cfg.contentInsets = NSDirectionalEdgeInsets(top: padding.top, leading: padding.left, bottom: padding.bottom, trailing: padding.right)
            var attributes = AttributeContainer()
            attributes.font = DSTypo.body
            attributes.foregroundColor = DSColor.accent
            let attributedTitle = AttributedString(title, attributes: attributes)
            
            cfg.attributedTitle = attributedTitle
            self.configuration = cfg
        } else {
            setTitle(title, for: .normal)
            titleLabel?.font = DSTypo.body
            backgroundColor = DSColor.surface
            setTitleColor(DSColor.accent, for: .normal)
            layer.cornerRadius = 8
            contentEdgeInsets = padding
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError(Cammon.fatalError)
    }
}

private final class SynonymPillContainerView: UIView {
    
    private let pillSpacing: CGFloat = DSSpacing.x2
    
    var synonyms: [String] = [] {
        didSet {
            setupPills()
        }
    }
    
    private var pillButtons: [SynonymPillButton] = []
    private var totalHeight: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError(Cammon.fatalError)
    }
    
    private func setupPills() {
        pillButtons.forEach { $0.removeFromSuperview() }
        pillButtons = []

        for synonym in synonyms {
            let pillButton = SynonymPillButton(title: synonym)
            addSubview(pillButton)
            pillButtons.append(pillButton)
        }
        
        invalidateIntrinsicContentSize()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard !pillButtons.isEmpty else {
            totalHeight = 0
            return
        }
        
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        let containerWidth = self.bounds.width
        
        var currentLineHeight: CGFloat = 0

        for pill in pillButtons {
            let pillSize = pill.intrinsicContentSize
            
            if (currentX + pillSize.width) > containerWidth && currentX != 0 {
                currentX = 0
                currentY += currentLineHeight + pillSpacing
                currentLineHeight = 0
            }
            
            pill.frame = CGRect(x: currentX, y: currentY, width: pillSize.width, height: pillSize.height)
            
            currentX += pillSize.width + pillSpacing
            currentLineHeight = max(currentLineHeight, pillSize.height)
        }
        
        totalHeight = currentY + currentLineHeight
        
        invalidateIntrinsicContentSize()
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: totalHeight)
    }
}
