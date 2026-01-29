//
//  ARScannerViewController.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 29.01.2026.
//

import ARKit
import SceneKit
import UIKit

protocol ARScannerViewInput: AnyObject {
    func render(state: ARScannerState)
}

final class ARScannerViewController: UIViewController, ARScannerViewInput {
    var presenter: ARScannerViewOutput!

    private var currentPixelBuffer: CVPixelBuffer?
    private var overlayViews: [UIView] = []
    private var currentResults: [ARDetectionResult] = []
    private var selectedIndex: Int = 0

    // MARK: - UI Components

    private lazy var sceneView: ARSCNView = {
        let view = ARSCNView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.session.delegate = self
        view.autoenablesDefaultLighting = true
        return view
    }()

    private lazy var gradientOverlay: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.black.withAlphaComponent(0.6).cgColor,
            UIColor.clear.cgColor,
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.8).cgColor,
        ]
        layer.locations = [0, 0.2, 0.6, 1.0]
        return layer
    }()

    private lazy var viewfinderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        view.layer.borderWidth = 1.5
        view.layer.cornerRadius = 20
        return view
    }()

    private lazy var cornerTopLeft: UIView = { makeCorner() }()
    private lazy var cornerTopRight: UIView = { makeCorner() }()
    private lazy var cornerBottomLeft: UIView = { makeCorner() }()
    private lazy var cornerBottomRight: UIView = { makeCorner() }()

    private lazy var scanButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false

        let config = UIImage.SymbolConfiguration(pointSize: 26, weight: .semibold)
        button.setImage(
            UIImage(systemName: "camera.viewfinder", withConfiguration: config), for: .normal)
        button.tintColor = .white

        button.backgroundColor = DSColor.accent
        button.layer.cornerRadius = 32
        button.layer.shadowColor = DSColor.accent.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 8)
        button.layer.shadowRadius = 20
        button.layer.shadowOpacity = 0.5

        button.addTarget(self, action: #selector(didTapScan), for: .touchUpInside)
        return button
    }()

    private lazy var pulseRing: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = DSColor.accent.withAlphaComponent(0.25)
        view.layer.cornerRadius = 42
        view.isUserInteractionEnabled = false
        return view
    }()

    // MARK: - Result Display Container

    private lazy var resultContainer: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let view = UIVisualEffectView(effect: blur)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()

    private lazy var resultHeaderStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()

    private lazy var objectCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.textColor = .white
        label.backgroundColor = DSColor.accent
        label.textAlignment = .center
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        return label
    }()

    private lazy var resultTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .white.withAlphaComponent(0.7)
        label.text = Strings.arDetectedObjects
        return label
    }()

    private lazy var carouselCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.itemSize = CGSize(width: 160, height: 120)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        cv.register(DetectionResultCell.self, forCellWithReuseIdentifier: "DetectionResultCell")
        cv.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return cv
    }()

    private lazy var statusView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let view = UIVisualEffectView(effect: blur)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()

    private lazy var statusIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private lazy var instructionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .white.withAlphaComponent(0.9)
        label.textAlignment = .center
        label.text = Strings.arInstruction
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        presenter.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientOverlay.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startARSession()
        startPulseAnimation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    // MARK: - Setup

    private func setupUI() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = .black

        view.addSubview(sceneView)
        view.layer.addSublayer(gradientOverlay)
        view.addSubview(viewfinderView)
        view.addSubview(cornerTopLeft)
        view.addSubview(cornerTopRight)
        view.addSubview(cornerBottomLeft)
        view.addSubview(cornerBottomRight)
        view.addSubview(instructionLabel)

        view.addSubview(pulseRing)
        view.addSubview(scanButton)
        view.addSubview(resultContainer)
        view.addSubview(statusView)

        resultContainer.contentView.addSubview(resultHeaderStack)
        resultContainer.contentView.addSubview(carouselCollectionView)

        resultHeaderStack.addArrangedSubview(objectCountLabel)
        resultHeaderStack.addArrangedSubview(resultTitleLabel)

        statusView.contentView.addSubview(statusIcon)
        statusView.contentView.addSubview(statusLabel)
    }

    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        let viewfinderSize: CGFloat = 260

        NSLayoutConstraint.activate([
            // Scene View
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Close Button

            // Instruction
            instructionLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 16),
            instructionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Viewfinder
            viewfinderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            viewfinderView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),
            viewfinderView.widthAnchor.constraint(equalToConstant: viewfinderSize),
            viewfinderView.heightAnchor.constraint(equalToConstant: viewfinderSize),

            // Corners
            cornerTopLeft.topAnchor.constraint(equalTo: viewfinderView.topAnchor, constant: -2),
            cornerTopLeft.leadingAnchor.constraint(
                equalTo: viewfinderView.leadingAnchor, constant: -2),

            cornerTopRight.topAnchor.constraint(equalTo: viewfinderView.topAnchor, constant: -2),
            cornerTopRight.trailingAnchor.constraint(
                equalTo: viewfinderView.trailingAnchor, constant: 2),

            cornerBottomLeft.bottomAnchor.constraint(
                equalTo: viewfinderView.bottomAnchor, constant: 2),
            cornerBottomLeft.leadingAnchor.constraint(
                equalTo: viewfinderView.leadingAnchor, constant: -2),

            cornerBottomRight.bottomAnchor.constraint(
                equalTo: viewfinderView.bottomAnchor, constant: 2),
            cornerBottomRight.trailingAnchor.constraint(
                equalTo: viewfinderView.trailingAnchor, constant: 2),

            // Object Count Label
            objectCountLabel.widthAnchor.constraint(equalToConstant: 24),
            objectCountLabel.heightAnchor.constraint(equalToConstant: 24),

            // Pulse Ring
            pulseRing.centerXAnchor.constraint(equalTo: scanButton.centerXAnchor),
            pulseRing.centerYAnchor.constraint(equalTo: scanButton.centerYAnchor),
            pulseRing.widthAnchor.constraint(equalToConstant: 84),
            pulseRing.heightAnchor.constraint(equalToConstant: 84),

            // Scan Button
            scanButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -30),
            scanButton.widthAnchor.constraint(equalToConstant: 64),
            scanButton.heightAnchor.constraint(equalToConstant: 64),

            // Result Container
            resultContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            resultContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            resultContainer.bottomAnchor.constraint(equalTo: scanButton.topAnchor, constant: -20),
            resultContainer.heightAnchor.constraint(equalToConstant: 170),

            resultHeaderStack.topAnchor.constraint(
                equalTo: resultContainer.topAnchor, constant: 14),
            resultHeaderStack.leadingAnchor.constraint(
                equalTo: resultContainer.leadingAnchor, constant: 16),

            carouselCollectionView.topAnchor.constraint(
                equalTo: resultHeaderStack.bottomAnchor, constant: 12),
            carouselCollectionView.leadingAnchor.constraint(equalTo: resultContainer.leadingAnchor),
            carouselCollectionView.trailingAnchor.constraint(
                equalTo: resultContainer.trailingAnchor),
            carouselCollectionView.bottomAnchor.constraint(
                equalTo: resultContainer.bottomAnchor, constant: -12),

            // Status View
            statusView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusView.centerYAnchor.constraint(equalTo: viewfinderView.centerYAnchor),
            statusView.heightAnchor.constraint(equalToConstant: 44),

            statusIcon.leadingAnchor.constraint(equalTo: statusView.leadingAnchor, constant: 14),
            statusIcon.centerYAnchor.constraint(equalTo: statusView.centerYAnchor),
            statusIcon.widthAnchor.constraint(equalToConstant: 20),
            statusIcon.heightAnchor.constraint(equalToConstant: 20),

            statusLabel.leadingAnchor.constraint(equalTo: statusIcon.trailingAnchor, constant: 8),
            statusLabel.trailingAnchor.constraint(
                equalTo: statusView.trailingAnchor, constant: -14),
            statusLabel.centerYAnchor.constraint(equalTo: statusView.centerYAnchor),
        ])
    }

    // MARK: - Helpers

    private func makeCorner() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = DSColor.accent
        view.layer.cornerRadius = 2
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 28),
            view.heightAnchor.constraint(equalToConstant: 5),
        ])
        return view
    }

    private func startPulseAnimation() {
        pulseRing.alpha = 0.5
        pulseRing.transform = .identity

        UIView.animate(
            withDuration: 1.8,
            delay: 0,
            options: [.repeat, .autoreverse, .allowUserInteraction],
            animations: {
                self.pulseRing.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
                self.pulseRing.alpha = 0.15
            }
        )
    }

    private func startARSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        sceneView.session.run(configuration)
    }

    // MARK: - Bounding Box Overlays

    private func clearOverlays() {
        overlayViews.forEach { $0.removeFromSuperview() }
        overlayViews.removeAll()
    }

    private func drawBoundingBoxes(for results: [ARDetectionResult]) {
        clearOverlays()

        for (index, result) in results.enumerated() {
            let overlay = createOverlayView(for: result, index: index)
            overlay.isUserInteractionEnabled = false
            view.insertSubview(overlay, aboveSubview: sceneView)
            overlayViews.append(overlay)
        }

        // Ensure interactive elements stay on top
        view.bringSubviewToFront(resultContainer)
        view.bringSubviewToFront(scanButton)
        view.bringSubviewToFront(pulseRing)

        view.bringSubviewToFront(statusView)
    }

    private func createOverlayView(for result: ARDetectionResult, index: Int) -> UIView {
        let screenWidth = view.bounds.width
        let screenHeight = view.bounds.height

        // Vision coordinates: origin at bottom-left
        let x = result.boundingBox.origin.x * screenWidth
        let y = (1 - result.boundingBox.origin.y - result.boundingBox.height) * screenHeight
        let width = result.boundingBox.width * screenWidth
        let height = result.boundingBox.height * screenHeight

        let frame = CGRect(x: x, y: y, width: width, height: height)
        let isSelected = index == selectedIndex

        let container = UIView(frame: frame)
        container.backgroundColor = .clear

        // Animated border
        let borderView = UIView(frame: container.bounds)
        borderView.backgroundColor = .clear
        borderView.layer.borderColor =
            (isSelected ? DSColor.accent : UIColor.white.withAlphaComponent(0.7)).cgColor
        borderView.layer.borderWidth = isSelected ? 3 : 2
        borderView.layer.cornerRadius = 12

        if isSelected {
            borderView.layer.shadowColor = DSColor.accent.cgColor
            borderView.layer.shadowRadius = 8
            borderView.layer.shadowOpacity = 0.5
            borderView.layer.shadowOffset = .zero
        }

        container.addSubview(borderView)

        // Label pill
        let pillView = UIView()
        pillView.backgroundColor =
            isSelected ? DSColor.accent : UIColor.black.withAlphaComponent(0.75)
        pillView.layer.cornerRadius = 10
        pillView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = result.turkishWord
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false

        let indexBadge = UILabel()
        indexBadge.text = "\(index + 1)"
        indexBadge.font = .systemFont(ofSize: 10, weight: .bold)
        indexBadge.textColor = isSelected ? DSColor.accent : .white
        indexBadge.backgroundColor = isSelected ? .white : UIColor.white.withAlphaComponent(0.2)
        indexBadge.textAlignment = .center
        indexBadge.layer.cornerRadius = 8
        indexBadge.clipsToBounds = true
        indexBadge.translatesAutoresizingMaskIntoConstraints = false

        pillView.addSubview(indexBadge)
        pillView.addSubview(label)
        container.addSubview(pillView)

        NSLayoutConstraint.activate([
            pillView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            pillView.bottomAnchor.constraint(equalTo: container.topAnchor, constant: -6),
            pillView.heightAnchor.constraint(equalToConstant: 28),

            indexBadge.leadingAnchor.constraint(equalTo: pillView.leadingAnchor, constant: 6),
            indexBadge.centerYAnchor.constraint(equalTo: pillView.centerYAnchor),
            indexBadge.widthAnchor.constraint(equalToConstant: 16),
            indexBadge.heightAnchor.constraint(equalToConstant: 16),

            label.leadingAnchor.constraint(equalTo: indexBadge.trailingAnchor, constant: 6),
            label.trailingAnchor.constraint(equalTo: pillView.trailingAnchor, constant: -10),
            label.centerYAnchor.constraint(equalTo: pillView.centerYAnchor),
        ])

        return container
    }

    // MARK: - Actions

    @objc private func didTapScan() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        UIView.animate(
            withDuration: 0.1,
            animations: {
                self.scanButton.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
            }
        ) { _ in
            UIView.animate(withDuration: 0.1) {
                self.scanButton.transform = .identity
            }
        }

        presenter.didTapScan(pixelBuffer: currentPixelBuffer)
    }

    // MARK: - Render State

    func render(state: ARScannerState) {
        resultContainer.isHidden = true
        statusView.isHidden = true
        scanButton.isEnabled = true
        viewfinderView.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        clearOverlays()

        switch state {
        case .idle:
            currentResults = []
            instructionLabel.text = Strings.arInstruction

        case .scanning:
            statusView.isHidden = false
            statusIcon.image = UIImage(systemName: "circle.dotted")
            statusLabel.text = Strings.arScanning
            scanButton.isEnabled = false
            viewfinderView.layer.borderColor = DSColor.accent.cgColor
            instructionLabel.text = Strings.arSearchingObjects

            let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
            rotation.toValue = CGFloat.pi * 2
            rotation.duration = 1.2
            rotation.repeatCount = .infinity
            statusIcon.layer.add(rotation, forKey: "rotationAnimation")

        case .detected(let results):
            statusIcon.layer.removeAllAnimations()
            currentResults = results
            selectedIndex = 0
            viewfinderView.layer.borderColor = DSColor.favoriteGreen.cgColor
            instructionLabel.text = Strings.arObjectsDetected(results.count)

            // Show result container
            resultContainer.isHidden = false
            objectCountLabel.text = "\(results.count)"
            carouselCollectionView.reloadData()

            // Draw bounding boxes
            drawBoundingBoxes(for: results)

            // Smooth entrance animation
            resultContainer.transform = CGAffineTransform(translationX: 0, y: 60)
            resultContainer.alpha = 0
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 0.85,
                initialSpringVelocity: 0.2
            ) {
                self.resultContainer.transform = .identity
                self.resultContainer.alpha = 1
            }

            UINotificationFeedbackGenerator().notificationOccurred(.success)

        case .error(let message):
            statusIcon.layer.removeAllAnimations()
            statusView.isHidden = false
            statusIcon.image = UIImage(systemName: "exclamationmark.triangle.fill")
            statusIcon.tintColor = .orange
            statusLabel.text = message
            viewfinderView.layer.borderColor = UIColor.orange.cgColor
            instructionLabel.text = Strings.arTryAgain
        }
    }
}

// MARK: - ARKit Delegates

extension ARScannerViewController: ARSCNViewDelegate, ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        currentPixelBuffer = frame.capturedImage
    }
}

// MARK: - Collection View

extension ARScannerViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int)
        -> Int
    {
        return currentResults.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell
    {
        let cell =
            collectionView.dequeueReusableCell(
                withReuseIdentifier: "DetectionResultCell", for: indexPath) as! DetectionResultCell
        let result = currentResults[indexPath.item]
        cell.configure(
            with: result, index: indexPath.item, isSelected: indexPath.item == selectedIndex)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.item
        collectionView.reloadData()
        drawBoundingBoxes(for: currentResults)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        // Scroll to selected
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}

// MARK: - Detection Result Cell

final class DetectionResultCell: UICollectionViewCell {

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        return view
    }()

    private let indexBadge: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        return label
    }()

    private let flagsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18)
        label.text = "🇺🇸 → 🇹🇷"
        label.textAlignment = .center
        return label
    }()

    private let englishLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let turkishLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .heavy)
        label.textColor = DSColor.accent
        label.textAlignment = .center
        return label
    }()

    private let confidencePill: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = DSColor.favoriteGreen.withAlphaComponent(0.2)
        view.layer.cornerRadius = 8
        return view
    }()

    private let confidenceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = DSColor.favoriteGreen
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(indexBadge)
        containerView.addSubview(flagsLabel)
        containerView.addSubview(englishLabel)
        containerView.addSubview(turkishLabel)
        containerView.addSubview(confidencePill)
        confidencePill.addSubview(confidenceLabel)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            indexBadge.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            indexBadge.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            indexBadge.widthAnchor.constraint(equalToConstant: 20),
            indexBadge.heightAnchor.constraint(equalToConstant: 20),

            flagsLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            flagsLabel.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor, constant: -10),

            englishLabel.topAnchor.constraint(equalTo: indexBadge.bottomAnchor, constant: 8),
            englishLabel.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor, constant: 10),
            englishLabel.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor, constant: -10),

            turkishLabel.topAnchor.constraint(equalTo: englishLabel.bottomAnchor, constant: 2),
            turkishLabel.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor, constant: 10),
            turkishLabel.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor, constant: -10),

            confidencePill.bottomAnchor.constraint(
                equalTo: containerView.bottomAnchor, constant: -10),
            confidencePill.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            confidencePill.heightAnchor.constraint(equalToConstant: 20),

            confidenceLabel.topAnchor.constraint(equalTo: confidencePill.topAnchor),
            confidenceLabel.bottomAnchor.constraint(equalTo: confidencePill.bottomAnchor),
            confidenceLabel.leadingAnchor.constraint(
                equalTo: confidencePill.leadingAnchor, constant: 10),
            confidenceLabel.trailingAnchor.constraint(
                equalTo: confidencePill.trailingAnchor, constant: -10),
        ])
    }

    func configure(with result: ARDetectionResult, index: Int, isSelected: Bool) {
        englishLabel.text = result.englishWord
        turkishLabel.text = result.turkishWord
        confidenceLabel.text = "✓ \(String(format: "%.0f", result.confidence * 100))%"

        indexBadge.text = "\(index + 1)"
        indexBadge.textColor = isSelected ? DSColor.accent : .white
        indexBadge.backgroundColor = isSelected ? .white : UIColor.white.withAlphaComponent(0.15)

        containerView.layer.borderColor =
            isSelected
            ? DSColor.accent.cgColor
            : UIColor.white.withAlphaComponent(0.1).cgColor
        containerView.layer.borderWidth = isSelected ? 2.5 : 2
        containerView.backgroundColor =
            isSelected
            ? DSColor.accent.withAlphaComponent(0.15)
            : UIColor.white.withAlphaComponent(0.08)

        if isSelected {
            containerView.layer.shadowColor = DSColor.accent.cgColor
            containerView.layer.shadowRadius = 10
            containerView.layer.shadowOpacity = 0.4
            containerView.layer.shadowOffset = .zero
        } else {
            containerView.layer.shadowOpacity = 0
        }
    }
}
