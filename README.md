# Falcon iOS SDK

Falcon is an iOS SDK for embedding ad placements directly inside your app. Placements are rendered inside a `WKWebView`-backed `FalconEmbeddedView` and communicate with the Falcon backend over a lightweight JavaScript bridge. The SDK requires iOS 14 or later and is distributed via Swift Package Manager.

---

## Swift Package Manager

1. In Xcode, choose **File > Add Package Dependencies…**
2. Enter the repository URL: `https://github.com/falcon-protocol/falcon-ios-sdk.git`
3. Under **Dependency Rule**, select **Up to Next Major Version**.
4. Add the `FalconSDK` library to your app target.

Or in a `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/falcon-protocol/falcon-ios-sdk.git", from: "1.3.2"),
],
```

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

### Overlay Placement

An overlay placement presents as a full-screen modal — no `FalconEmbeddedView` needed. Pass `.overlay` as the placement and the SDK presents the modal itself. The web content dismisses it when the user closes the offer (via the `close` bridge event). Callbacks and events (`onLoad`, `onUnload`, `onError`, `.placementInteractive`, `.placementCompleted`) behave identically to inline placements.

**UIKit**

Call `Falcon.execute` from any action (e.g. a button tap or `viewDidAppear`):

```swift
Falcon.execute(
    attributes: attributes,
    placement: .overlay,
    onLoad: {
        print("overlay loaded")
    },
    onUnload: {
        print("overlay dismissed")
    },
    onError: { error in
        print("overlay error: \(error)")
    }
)
```

**SwiftUI**

Call `Falcon.execute` inside a button action or other event handler (no wrapper view required):

```swift
Button("Show offer") {
    Falcon.execute(
        attributes: attributes,
        placement: .overlay,
        onLoad: { print("overlay loaded") },
        onUnload: { print("overlay dismissed") },
        onError: { error in print("overlay error: \(error)") }
    )
}
```

The SDK finds the frontmost view controller automatically and presents the full-screen modal. If no presenter is available, `onError` is called with `FalconError.placementLoadError`.

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

Handlers retain whatever they capture (often a view controller) until removed or overwritten — call `Falcon.removeEventsHandler(layoutId:)` when you no longer need the subscription.

---

### SwiftUI

`FalconEmbeddedSwiftUIView` is a SwiftUI-native wrapper around `FalconEmbeddedView`. It sizes itself automatically using the same height-constraint mechanism. Execution starts on the next main-queue turn after the view is mounted, so callbacks never fire during a SwiftUI view update and can safely mutate `@State`.

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
| `placementMapping` | `[String: String]` | `[:]` | Maps your app's placement identifiers (`layout_id` / `view` from the attributes dictionary) to Falcon placement ids. |
| `diagnosticBeaconsEnabled` | `Bool` | `true` | When true, POSTs PII-free error beacons on placement failure (see Diagnostics below). |
| `diagnosticsURL` | `URL?` | `nil` | Overrides the beacon endpoint. When nil, beacons go to `baseURL + /sdk/diagnostics`. |

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

### Migrating from another ad SDK

The Falcon SDK is designed as a drop-in for the common ad-SDK integration surface: an init call, an embedded view, and an execute call that takes an attributes dictionary. If your previous SDK follows that shape, its import/init/view/execute calls map 1:1 — migrate with a find/replace, substituting your previous SDK's names on the left:

```diff
- import PreviousAdSDK
+ import FalconSDK

- PreviousAdSDK.initSdk(apiKey: "API_KEY")
+ Falcon.initSdk(apiKey: "API_KEY")

- @IBOutlet weak var embeddedView: PreviousAdSDKEmbeddedView!
+ @IBOutlet weak var embeddedView: FalconEmbeddedView!

- PreviousAdSDK.execute(attributes: attributes, placement: .inline(embeddedView))
+ Falcon.execute(attributes: attributes, placement: .inline(embeddedView))
```

Attribute dictionaries, callbacks, style fields, the sandbox flag, and SwiftUI usage keep the same shape. If your previous placement identifiers differ from your Falcon placement ids, map them with `FalconConfig.placementMapping` (see Configuration above) instead of editing every call site.

---

## Privacy

FalconSDK ships an Apple privacy manifest (`PrivacyInfo.xcprivacy`) in both the Swift package and the distributed `FalconSDK.xcframework`.

**What it declares:**

- **Tracking:** `NSPrivacyTracking = false`. Falcon does not link user data collected from your app with data from other companies' apps or websites, and does not share data with data brokers. (This decision is revisited if Falcon ever introduces cross-shop identity linking.)
- **Collected data:** email address, name, and purchase history — *only if your app passes them* as attributes to `Falcon.execute`. Each is declared as linked to identity and **not** used for tracking, with purpose "third-party advertising" (displaying promotional offers).
- **Required-reason APIs:** none. The SDK does not use UserDefaults, file timestamps, system uptime, disk space, or keyboard APIs.

**What this means for your App Store submission:** Xcode aggregates this manifest into your app's privacy report automatically. In your app's privacy nutrition label, declare email/name/purchase-history as shared with Falcon only if your integration actually passes those attributes. No App Tracking Transparency (ATT) prompt is required for FalconSDK.

The manifest also declares **`NSPrivacyCollectedDataTypeOtherDiagnosticData`** (linked=false, tracking=false, purpose=AppFunctionality) for the error beacons described in the Diagnostics section below.

---

## Security

- **Bridge origin check:** the SDK accepts bridge messages only from the placement page's main frame and origin (scheme, host and port). Iframes inside a placement cannot resize, click, close or report errors.
- **Navigation:** the placement webview stays on the placement host. Taps on links open in `SFSafariViewController` (or the system for non-web links), never inside your app's webview. Other main-frame navigations are blocked.
- **Isolated storage:** each webview uses a non-persistent website data store, so ad content never sees your app's cookies or web storage.
- **Web Inspector:** the shipped `FalconSDK.xcframework` never enables Safari Web Inspector on its webviews.

---

## Diagnostics

FalconSDK emits granular diagnostic events on every placement failure through three channels:

1. **`FalconDiagnosticsDelegate`** — opt-in host hook for routing into your own tooling (Sentry, Datadog, etc.)
2. **PII-free HTTP error beacons** — automatic `POST {baseURL}/sdk/diagnostics` on failure (on by default)
3. **`os.Logger`** — lines under subsystem `us.falconlabs.FalconSDK`, category `diagnostics`

### Host delegate (opt-in)

Set `Falcon.diagnosticsDelegate` once at launch to receive a `FalconDiagnostic` for every SDK failure:

```swift
class MyDiagnosticsHandler: FalconDiagnosticsDelegate {
    func falconDidEncounter(_ diagnostic: FalconDiagnostic) {
        // diagnostic.code    — FalconDiagnosticCode (granular reason)
        // diagnostic.message — human-readable description (local only, never sent in beacons)
        // diagnostic.placement, diagnostic.layoutId — routing context
        MyErrorTracker.capture(diagnostic.code.rawValue)
    }
}

// In your AppDelegate or app init:
Falcon.diagnosticsDelegate = myDiagnosticsHandler
```

`FalconDiagnosticCode` cases:

| Code | When |
|---|---|
| `initNotCalled` | `execute` called before `initSdk` |
| `attributeMappingFailed` | attributes did not resolve to a placement |
| `urlConstructionFailed` | webview URL could not be built |
| `webviewNavigationFailed` | `WKWebView` navigation error |
| `webviewProvisionalNavigationFailed` | `WKWebView` provisional navigation error |
| `webviewHTTPError` | main-frame webview response had HTTP status >= 400 (load cancelled, placement failed) |
| `webviewLoadTimedOut` | no bridge message arrived within 15s of starting the load (placement failed; overlay dismissed) |
| `bridgeReportedError` | JS bridge posted an `error` event |
| `noPresenter` | overlay found no frontmost view controller |

### Error beacons

Beacons are **on by default**. To disable them (e.g. for privacy-sensitive environments):

```swift
Falcon.initSdk(
    apiKey: "YOUR_API_KEY",
    config: FalconConfig(diagnosticBeaconsEnabled: false)
)
```

To override the beacon endpoint:

```swift
Falcon.initSdk(
    apiKey: "YOUR_API_KEY",
    config: FalconConfig(diagnosticsURL: URL(string: "https://telemetry.example.com/ingest")!)
)
```

Beacons are fire-and-forget, PII-free (no user attributes, email, API key, or free-form message text), and silently drop on network failure. The only host-supplied fields a beacon carries are `placement` and `layoutId` (your `placement_details.view` / `layout_id`) as routing identifiers — **do not put user data in `view`/`layout_id`**, as they are sent in diagnostics (the SDK caps each at 128 characters).

Beacons are only sent after `initSdk` has been called. The `initNotCalled` diagnostic never reaches the network — it surfaces through `FalconDiagnosticsDelegate` and `os.Logger` only.

### os.Logger

All diagnostic events are also logged to the system log. In Console.app, filter by subsystem `us.falconlabs.FalconSDK` to see them. The `code` field is `.public`; the `message` is `.private` and stays on-device.
