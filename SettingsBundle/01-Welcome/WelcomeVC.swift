//
//  WelcomeVC.swift
//  SettingsBundle
//
//  Created by Tam Nguyen M. on 3/26/19.
//  Copyright © 2019 Tam Nguyen M. All rights reserved.
//

import UIKit

final class WelcomeVC: UIViewController {

    @IBOutlet private weak var endpointLabel: UILabel!
    @IBOutlet private weak var blurView: UIView!

    private var welcomeView: WelcomeView?

    override func viewDidLoad() {
        super.viewDidLoad()
        configObserver()
        configBlurView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configWelcomePopUp()
        configEndpointLabel()
    }

    private func configObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(udValuesDidChange),
                                               name: UserDefaults.didChangeNotification,
                                               object: nil)
    }

    @objc private func udValuesDidChange(notification: Notification) {
        configEndpointLabel()
    }

    private func configBlurView() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(blurViewTouchUpInside))
        blurView.addGestureRecognizer(gesture)
    }

    @objc private func blurViewTouchUpInside() {
        setWelcomeViewHidden(true)
    }

    private func configWelcomePopUp() {
        let isFirstTime = ud.bool(forKey: InfoKey.kDidOpenApp.rawValue)
        if !isFirstTime {
            setWelcomeViewHidden(false)
        }
    }

    private func setWelcomeViewHidden(_ isHidden: Bool, completion: (() -> Void)? = nil) {
        if isHidden {
            ud.set(true, forKey: InfoKey.kDidOpenApp.rawValue)
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                guard let this = self else { return }
                this.welcomeView?.alpha = 0
            }, completion: { [weak self] _ in
                guard let this = self else { return }
                this.welcomeView = nil
                UIView.animate(withDuration: 0.3, animations: { [weak self] in
                    guard let this = self else { return }
                    this.blurView.alpha = 0
                }, completion: { [weak self] _ in
                    guard let this = self else { return }
                    this.blurView.isHidden = true
                    completion?()
                })
            })

        } else {
            guard let welcomeView = Bundle.main.loadNibNamed("WelcomeView", owner: self, options: nil)?.first as? WelcomeView else { return }
            self.welcomeView = welcomeView
            welcomeView.delegate = self
            welcomeView.alpha = 0

            view.addSubview(welcomeView)
            welcomeView.translatesAutoresizingMaskIntoConstraints = false
            welcomeView.widthAnchor.constraint(equalToConstant: 300).isActive = true
            welcomeView.heightAnchor.constraint(equalToConstant: 400).isActive = true
            welcomeView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            welcomeView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

            blurView.isHidden = false
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                guard let this = self else { return }
                this.blurView.alpha = 1
            }, completion: { _ in
                UIView.animate(withDuration: 0.2, animations: {
                    welcomeView.alpha = 1
                }, completion: { _ in
                    completion?()
                })
            })
        }
    }

    private func configEndpointLabel() {
        if let endpoint = SettingsManager.shared.getSettingStringValue(forSettingKey: SettingsManager.SettingKey.kEndpoint) {
            endpointLabel.text = endpoint
        } else {
            endpointLabel.text = "[No endpoint]"
        }
    }
}

extension WelcomeVC: WelcomeViewDelegate {
    func welcomeView(_ welcomeView: WelcomeView, needsPerform action: WelcomeView.Action) {
        switch action {
        case .close:
            setWelcomeViewHidden(true)
        }
    }
}
