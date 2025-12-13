//
//  SplashViewController.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 3.11.2025.
//

import UIKit
import AVFoundation

protocol SplashViewInput: AnyObject {
    func playVideo()
    func showAlert(title: String, message: String)
}

final class SplashViewController: UIViewController, SplashViewInput {

    var presenter: SplashViewOutput!
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
    private let videoContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private let footerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 1
        label.adjustsFontForContentSizeCategory = true
        label.textColor = DSColor.textSecondary
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOpacity = 0.35
        label.layer.shadowRadius = 2
        label.layer.shadowOffset = CGSize(width: 0, height: 1)
        
        let title = "Lingoverse"
        let byline = "created by Can Sağnak"
        let full = "\(title)  •  \(byline)"
        let attr = NSMutableAttributedString(string: full)
        
        let titleRange = (full as NSString).range(of: title)
        let bylineRange = (full as NSString).range(of: byline)
        
        let titleFont = UIFont.systemFont(ofSize: 13, weight: .semibold)
        let bylineFont = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        attr.addAttribute(.font, value: titleFont, range: titleRange)
        attr.addAttribute(.font, value: bylineFont, range: bylineRange)
        attr.addAttribute(.kern, value: 0.2, range: NSRange(location: 0, length: attr.length))
        
        label.attributedText = attr
        label.isAccessibilityElement = true
        label.accessibilityLabel = "Lingoverse, created by Can Sağnak"
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupVideoPlayer()
        presenter.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = videoContainerView.bounds
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        view.backgroundColor = DSColor.splashBackground
        footerLabel.layer.shadowColor = DSColor.footerShadow.cgColor
        view.addSubview(videoContainerView)
        view.addSubview(footerLabel)
        
        NSLayoutConstraint.activate([
            videoContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            videoContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            videoContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            videoContainerView.heightAnchor.constraint(equalTo: videoContainerView.widthAnchor, multiplier: 9.0/16.0),
            
            footerLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            footerLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),
            footerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            footerLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
    }
    
    private func setupVideoPlayer() {
        guard let path = Bundle.main.path(forResource: "splashVideo", ofType: "mov") else {
            DispatchQueue.main.async {
                self.presenter.videoDidFinish()
            }
            return
        }
        
        let url = URL(fileURLWithPath: path)
        let playerItem = AVPlayerItem(url: url)
        playerItem.audioTimePitchAlgorithm = .spectral
        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill
        videoContainerView.clipsToBounds = true
        playerLayer?.backgroundColor = UIColor.clear.cgColor
        
        if let playerLayer = self.playerLayer {
            videoContainerView.layer.addSublayer(playerLayer)
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(videoDidFinish),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )
    }
    
    @objc private func videoDidFinish() {
        presenter.videoDidFinish()
    }

    func playVideo() {
        player?.seek(to: .zero)
        player?.playImmediately(atRate: 2.0)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Strings.retryButtonLabel, style: .default, handler: { [weak self] _ in
            self?.presenter.viewDidLoad()
        }))
        present(alert, animated: true)
    }
}
