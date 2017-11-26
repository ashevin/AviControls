# AviControls

A framework with a miscellaneous collection of of UI controls for iOS.

## RatingView
A `UIControl` for selecting a rating.  The image to be displayed must be provided via the `image` property, and should contain a transparent background for tinting.

### Usage

```swift
let ratingView = RatingView(...)
ratingView.image = UIImage(...)
ratingView.rating = 3
```

#### To allow selecting zero items:

```swift
ratingView.minimumRating = 0
```
