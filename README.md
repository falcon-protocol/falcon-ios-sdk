# Falcon iOS SDK

Falcon is an iOS SDK for embedding ad placements directly inside your app. Placements are rendered inside a `WKWebView`-backed `FalconEmbeddedView` and communicate with the Falcon backend over a lightweight JavaScript bridge. The SDK requires iOS 14 or later and is distributed via Swift Package Manager.

---

## Swift Package Manager

1. In Xcode, choose **File > Add Package Dependencies…**
2. Enter the repository URL: `https://github.com/falcon-protocol/falcon-ios-sdk.git`
3. Under **Dependency Rule**, select **Up to Next Major Version**.
4. Add `Falcon` to your app target.

---

## Integration Guide

### Initialize the iOS SDK

Call `Falcon.initSdk(apiKey:)` once at app launch, before any placement is executed. The recommended place is `application(_:didFinishLaunchingWithOptions:)` in your `AppDelegate`.

```swift
import UIKit
import FalconSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        Falcon.initSdk(apiKey: "YOUR_API_KEY")
        return true
    }
}
```

---

### Add an Inline Placement

**Storyboard**

1. Drag a plain `View` onto your scene.
2. In the Identity Inspector set the **Custom Class** to `FalconEmbeddedView` and the **Module** to `FalconSDK`.
3. Add **top**, **leading**, and **trailing** constraints to position the view.
4. Add a **height** constraint and set its constant to `0` — `FalconEmbeddedView` updates that height constraint automatically to match the rendered placement.

**Programmatic alternative**

```swift
let embeddedView = FalconEmbeddedView()
embeddedView.translatesAutoresizingMaskIntoConstraints = false
view.addSubview(embeddedView)
NSLayoutConstraint.activate([
    embeddedView.topAnchor.constraint(equalTo: someAnchor),
    embeddedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
    embeddedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    embeddedView.heightAnchor.constraint(equalToConstant: 0),
])
```

---

### Execute the Falcon SDK

Pass an attributes dictionary describing the user and the desired placement, along with a reference to the `FalconEmbeddedView` you wired up above.

```swift
import UIKit
import FalconSDK

class OrderStatusViewController: UIViewController {

    @IBOutlet weak var embeddedView: FalconEmbeddedView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let attributes: [String: Any] = [
            "user_details": [
                "email": "testing@falconlabs.us",
                "first_name": "first",
                "last_name": "last"
            ],
            "placement_details": [
                "layout_id": "APP_NATIVE_ESSENTIAL_0.1",
                "view": "ORDER_STATUS"
            ]
        ]

        Falcon.execute(attributes: attributes, placement: .inline(embeddedView))
    }
}
```

---

### Sandbox Mode

Pass `isSandbox: true` while developing and testing. Set it to `false` (the default) before releasing to production.

```swift
Falcon.execute(
    attributes: attributes,
    placement: .inline(embeddedView),
    isSandbox: true   // development only
)
```

---

### Style Param

Override the visual appearance of a placement by passing a `FalconStyle` value. All fields are optional; omit a field to keep the web layer's built-in default.

| Field | Type | Default |
|---|---|---|
| `widgetBackgroundColor` | `UIColor?` | `.clear` |
| `slotBackgroundColor` | `UIColor?` | `.white` |
| `slotPadding` | `Int?` | — |
| `acceptButtonBackgroundColor` | `UIColor?` | `#008363` |
| `acceptButtonTextColor` | `UIColor?` | `.white` |
| `promoCodeBackgroundColor` | `UIColor?` | `#2DA784` |
| `fontFamily` | `String?` | Roboto |

```swift
let style = FalconStyle(
    widgetBackgroundColor: .clear,
    slotBackgroundColor: .white,
    acceptButtonBackgroundColor: UIColor(red: 0, green: 0.514, blue: 0.388, alpha: 1),
    acceptButtonTextColor: .white,
    promoCodeBackgroundColor: UIColor(red: 0.176, green: 0.655, blue: 0.518, alpha: 1),
    fontFamily: "Roboto"
)

Falcon.execute(
    attributes: attributes,
    placement: .inline(embeddedView),
    style: style
)
```

---

### Callbacks

All callbacks are dispatched on the **main thread** and are safe to use for UI updates.

| Callback | Description |
|---|---|
| `onLoad` | Called once when the placement has rendered content and become visible. |
| `onUnload` | Called when the placement is removed from the UI (e.g. the user closed it). |
| `onError` | Called with a `FalconError` when the placement cannot be shown. |
| `onShouldShowLoadingIndicator` | Called immediately when `execute` begins — show your loading UI now. |
| `onShouldHideLoadingIndicator` | Called once the placement has settled (loaded or determined no-fill) — hide your loading UI. |

```swift
Falcon.execute(
    attributes: attributes,
    placement: .inline(embeddedView),
    onLoad: {
        print("placement loaded")
    },
    onUnload: {
        print("placement unloaded")
    },
    onError: { error in
        print("placement error: \(error)")
    },
    onShouldShowLoadingIndicator: {
        mySpinner.startAnimating()
    },
    onShouldHideLoadingIndicator: {
        mySpinner.stopAnimating()
    }
)
```

**Errors**

| Case | Meaning |
|---|---|
| `FalconError.initNotCalled` | `Falcon.execute` was called before `Falcon.initSdk`. |
| `FalconError.placementLoadError` | The placement failed to load from the Falcon backend. |

---

### Events

Subscribe to lifecycle events for a specific placement layout via `Falcon.events(layoutId:handler:)`. Pass the same `layout_id` string you include in the attributes dictionary.

```swift
Falcon.events(layoutId: "APP_NATIVE_ESSENTIAL_0.1") { event in
    switch event {
    case .placementInteractive:
        print("placement is interactive")
    case .placementCompleted:
        print("placement completed")
    case .placementFailure(let error):
        print("placement failed: \(error)")
    }
}
```

| Event | Description |
|---|---|
| `.placementInteractive` | More than 50% of the placement has been visible on screen for at least 1 second. Fired at most once per `execute` call. |
| `.placementCompleted` | The placement was engaged with and removed from the UI. |
| `.placementFailure(Error)` | The placement failed to load. |

---

### SwiftUI

`FalconEmbeddedSwiftUIView` is a SwiftUI-native wrapper around `FalconEmbeddedView`. It sizes itself automatically using the same height-constraint mechanism.

```swift
import SwiftUI
import FalconSDK

struct OrderStatusView: View {

    let attributes: [String: Any] = [
        "user_details": [
            "email": "testing@falconlabs.us",
            "first_name": "first",
            "last_name": "last"
        ],
        "placement_details": [
            "layout_id": "APP_NATIVE_ESSENTIAL_0.1",
            "view": "ORDER_STATUS"
        ]
    ]

    var body: some View {
        VStack {
            FalconEmbeddedSwiftUIView(
                attributes: attributes,
                style: nil,
                config: FalconConfig(),
                onLoad: { print("loaded") },
                onUnload: { print("unloaded") },
                onError: { error in print("error: \(error)") },
                onShouldShowLoadingIndicator: { print("show loading") },
                onShouldHideLoadingIndicator: { print("hide loading") },
                isSandbox: false
            )
        }
    }
}
```

Note: the `config:` parameter is accepted for API parity but is currently inert — the active configuration always comes from `Falcon.initSdk(apiKey:config:)`.

---

### Configuration (Falcon extension)

Pass a `FalconConfig` to `Falcon.initSdk(apiKey:config:)` to override defaults.

**`FalconConfig` properties**

| Property | Type | Default | Description |
|---|---|---|---|
| `baseURL` | `URL` | `https://pr.falconlabs.us` | Base URL of the Falcon web frontend. The SDK appends `/ui/webview` to construct the full placement URL. |
| `placementMapping` | `[String: String]` | `[:]` | Maps Disco-style placement identifiers to Falcon placement ids. |

**`placementMapping` lookup order**

Given `layout_id` and `view` from the attributes dictionary, the SDK looks up the placement id in this order:

1. `"<layout_id>/<view>"` — exact combined key
2. `"<view>"` — view only
3. `"<layout_id>"` — layout id only
4. Fallback: the raw `view` string is used as the placement id

**Example**

```swift
let config = FalconConfig(
    baseURL: URL(string: "https://pr.falconlabs.us")!,
    placementMapping: [
        "ORDER_STATUS": "your-falcon-placement-id"
    ]
)

Falcon.initSdk(apiKey: "YOUR_API_KEY", config: config)
```

---

### Migrating from Disco

The Falcon SDK is a drop-in replacement for the Disco SDK. Make the following find/replace changes:

```diff
- import DiscoSDK
+ import FalconSDK

- Disco.initSdk(apiKey: "API_KEY")
+ Falcon.initSdk(apiKey: "API_KEY")

- @IBOutlet weak var embeddedView: DiscoEmbeddedView!
+ @IBOutlet weak var embeddedView: FalconEmbeddedView!

- Disco.execute(attributes: attributes, placement: .inline(embeddedView))
+ Falcon.execute(attributes: attributes, placement: .inline(embeddedView))
```

Attribute dictionaries, callbacks, style fields, the sandbox flag, and SwiftUI usage are unchanged.
