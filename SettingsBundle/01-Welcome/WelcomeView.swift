//
//  WelcomeView.swift
//  SettingsBundle
//
//  Created by Tam Nguyen M. on 3/26/19.
//  Copyright © 2019 Tam Nguyen M. All rights reserved.
//

import UIKit

protocol WelcomeViewDelegate: class {
    func welcomeView(_ welcomeView: WelcomeView, needsPerform action: WelcomeView.Action)
}

final class WelcomeView: UIView {

    enum Action {
        case close
    }

    weak var delegate: WelcomeViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = true
        layer.cornerRadius = 5
    }

    @IBAction func closeButtonTouchUpInside(_ sender: Any) {
        delegate?.welcomeView(self, needsPerform: .close)
    }
}
