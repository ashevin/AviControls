//
//  RatingView.swift
//
//  Created by Avi Shevin on 26/11/2017.
//  Copyright © 2017 Avi Shevin. All rights reserved.
//

import UIKit

/**
 `RatingView` displays a configurable number of images, which the user may tap to indicate a
 rating.  Tapping an image will select it, along with the images leading up to it.  The user may
 also swipe to select a rating.
 */

public final class RatingView: UIControl, UIGestureRecognizerDelegate {
    /// The currently-selected rating.  Values are clamped between `minimumRating` and `maximumRating`.
    ///
    /// **Default value**: 1
    public var rating: UInt = 1 {
        didSet {
            rating = max(rating, minimummRating)
            rating = min(rating, maximumRating)

            highlightImages()
        }
    }

    /// Represents the maximum rating allowed.  Also sets the number of images to display.  Minimum-settable value is 1.
    ///
    /// **Default value**: 5
    public var maximumRating: UInt = 5 {
        didSet {
            maximumRating = max(maximumRating, 1)
            rating = min(rating, maximumRating)

            resetStackView()
        }
    }

    /// Represents the minimum rating allowed.  When a value of zero is set, the user may tap a single selected image to unselect it.
    ///
    /// **Default value**: 1
    public var minimummRating: UInt = 1 {
        didSet {
            minimummRating = min(minimummRating, maximumRating)
            rating = max(rating, minimummRating)

            resetStackView()
        }
    }

    /// The amount of space between images, in points.
    ///
    /// **Default value**: 20
    public var spacing: CGFloat = 20 {
        didSet {
            stackView.spacing = spacing
        }
    }

    /// The image to display.  The image is rendered as a template, and should have a transparent background.
    public var image: UIImage? = nil {
        didSet {
            image = image?.withRenderingMode(.alwaysTemplate)
            resetStackView()
        }
    }

    /// The color to tint images which are not selected.
    public var unselectedTintColor: UIColor = .lightGray {
        didSet {
            highlightImages()
        }
    }

    /// The color to tint images which are selected.
    public var selectedTintColor: UIColor = .yellow {
        didSet {
            highlightImages()
        }
    }

    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 1, height: UIViewNoIntrinsicMetric)
    }

    private let stackView = UIStackView()

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
    }

    private func commonInit() {
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = spacing
        stackView.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(stackView)

        self.addConstraints(
            [ NSLayoutAttribute.left, .right, .top, .bottom ].map {
                NSLayoutConstraint(item: stackView,
                                   attribute: $0,
                                   relatedBy: .equal,
                                   toItem: self,
                                   attribute: $0,
                                   multiplier: 1,
                                   constant: 0)
            }
        )

        resetStackView()

        addRecognizers()
    }

    private func resetStackView() {
        stackView.subviews.forEach {
            $0.removeFromSuperview()
        }

        guard let image = image else {
            return
        }

        for _ in 0..<maximumRating {
            let iv = UIImageView(image: image)

            iv.translatesAutoresizingMaskIntoConstraints = false
            iv.contentMode = .scaleAspectFit

            stackView.addArrangedSubview(iv)

            stackView.addConstraint(NSLayoutConstraint(item: iv,
                                                       attribute: .width,
                                                       relatedBy: .equal,
                                                       toItem: iv,
                                                       attribute: .height,
                                                       multiplier: 1,
                                                       constant: 0))
        }

        highlightImages()
    }

    private func highlightImages() {
        for i in 0..<stackView.subviews.count {
            if let iv = stackView.subviews[i] as? UIImageView {
                iv.tintColor = i < rating ? selectedTintColor : unselectedTintColor
            }
        }
    }

    private func viewInrersecting(point: CGPoint) -> UIView {
        for v in stackView.subviews {
            if v.frame.intersects(CGRect(origin: point, size: .zero)) {
                return v
            }
        }

        return stackView
    }

    private func addRecognizers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapRecognized(_:)))
        tap.delegate = self

        stackView.addGestureRecognizer(tap)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(panRecognized(_:)))
        pan.delegate = self

        stackView.addGestureRecognizer(pan)
    }

    @objc func tapRecognized(_ recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: recognizer.view)

        guard
            let iv = viewInrersecting(point: location) as? UIImageView,
            let index = stackView.subviews.index(of: iv)
            else {
                return
        }

        if rating == 1 && index == 0 && minimummRating == 0 {
            rating = 0
        }
        else {
            rating = UInt(index) + 1
        }

        sendActions(for: .valueChanged)
    }

    @objc func panRecognized(_ recognizer: UISwipeGestureRecognizer) {
        let location = recognizer.location(in: recognizer.view)

        guard
            let iv = viewInrersecting(point: location) as? UIImageView,
            let index = stackView.subviews.index(of: iv)
            else {
                return
        }

        rating = UInt(index) + 1

        sendActions(for: .valueChanged)
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
