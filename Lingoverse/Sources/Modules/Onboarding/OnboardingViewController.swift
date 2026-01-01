//
//  OnboardingViewController.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 1.01.2026.
//

import UIKit

protocol OnboardingViewInput: AnyObject {
    func configure(with pages: [OnboardingPage])
    func scrollToPage(_ index: Int)
}

final class OnboardingViewController: UIViewController, OnboardingViewInput {

    var presenter: OnboardingViewOutput!

    private var pages: [OnboardingPage] = []
    private var currentPageIndex = 0

    // MARK: - UI Components

    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.isPagingEnabled = true
        sv.showsHorizontalScrollIndicator = false
        sv.delegate = self
        sv.bounces = false
        return sv
    }()

    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 0
        return stack
    }()

    private lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.translatesAutoresizingMaskIntoConstraints = false
        pc.currentPageIndicatorTintColor = DSColor.accent
        pc.pageIndicatorTintColor = DSColor.textSecondary.withAlphaComponent(0.3)
        pc.addTarget(self, action: #selector(pageControlChanged), for: .valueChanged)
        return pc
    }()

    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Next", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)

        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.baseBackgroundColor = DSColor.accent
            config.baseForegroundColor = .white
            config.cornerStyle = .large
            config.contentInsets = NSDirectionalEdgeInsets(
                top: 16, leading: 32, bottom: 16, trailing: 32)
            button.configuration = config
        } else {
            button.backgroundColor = DSColor.accent
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 12
            button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 32, bottom: 16, right: 32)
        }

        return button
    }()

    private lazy var skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Skip", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(DSColor.textSecondary, for: .normal)
        button.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.viewDidLoad()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        view.addSubview(pageControl)
        view.addSubview(nextButton)
        view.addSubview(skipButton)

        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -20),

            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),

            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -24),

            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -24),
            nextButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 200),

            skipButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            skipButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 8),
        ])
    }

    // MARK: - OnboardingViewInput

    func configure(with pages: [OnboardingPage]) {
        self.pages = pages
        pageControl.numberOfPages = pages.count

        for subview in contentStackView.arrangedSubviews {
            subview.removeFromSuperview()
        }

        for page in pages {
            let pageView = OnboardingPageView()
            pageView.configure(with: page)
            pageView.translatesAutoresizingMaskIntoConstraints = false
            contentStackView.addArrangedSubview(pageView)
            pageView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        }

        updateButtonTitle()
    }

    func scrollToPage(_ index: Int) {
        let offsetX = CGFloat(index) * scrollView.bounds.width
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
    }

    // MARK: - Actions

    @objc private func nextButtonTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        if currentPageIndex < pages.count - 1 {
            currentPageIndex += 1
            scrollToPage(currentPageIndex)
            pageControl.currentPage = currentPageIndex
            updateButtonTitle()
            animatePageTransition()
        } else {
            presenter.didTapGetStarted()
        }
    }

    @objc private func skipButtonTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        presenter.didTapSkip()
    }

    @objc private func pageControlChanged() {
        currentPageIndex = pageControl.currentPage
        scrollToPage(currentPageIndex)
        updateButtonTitle()
    }

    private func updateButtonTitle() {
        let isLastPage = currentPageIndex == pages.count - 1

        UIView.animate(withDuration: 0.2) {
            if #available(iOS 15.0, *) {
                var config = self.nextButton.configuration
                config?.title = isLastPage ? "Get Started" : "Next"
                self.nextButton.configuration = config
            } else {
                self.nextButton.setTitle(isLastPage ? "Get Started" : "Next", for: .normal)
            }

            self.skipButton.alpha = isLastPage ? 0 : 1
        }
    }

    private func animatePageTransition() {
        let pageView = contentStackView.arrangedSubviews[currentPageIndex]
        pageView.alpha = 0
        pageView.transform = CGAffineTransform(translationX: 50, y: 0)

        UIView.animate(
            withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5
        ) {
            pageView.alpha = 1
            pageView.transform = .identity
        }
    }
}

// MARK: - UIScrollViewDelegate

extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageIndex = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        currentPageIndex = pageIndex
        pageControl.currentPage = pageIndex
        updateButtonTitle()
    }
}

// MARK: - OnboardingPageView

private final class OnboardingPageView: UIView {

    private lazy var iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.tintColor = DSColor.accent
        return iv
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = DSColor.textPrimary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = DSColor.textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 24
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError(Cammon.fatalError)
    }

    private func setupUI() {
        addSubview(contentStack)
        contentStack.addArrangedSubview(iconImageView)
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(descriptionLabel)

        contentStack.setCustomSpacing(32, after: iconImageView)
        contentStack.setCustomSpacing(16, after: titleLabel)

        NSLayoutConstraint.activate([
            contentStack.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),

            iconImageView.widthAnchor.constraint(equalToConstant: 120),
            iconImageView.heightAnchor.constraint(equalToConstant: 120),
        ])
    }

    func configure(with page: OnboardingPage) {
        iconImageView.image = UIImage(systemName: page.iconName)?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 60, weight: .light))
        titleLabel.text = page.title
        descriptionLabel.text = page.description
    }
}
