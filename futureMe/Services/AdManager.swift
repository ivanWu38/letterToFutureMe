import Foundation
import GoogleMobileAds
import UIKit

class AdManager: NSObject, ObservableObject {
    static let shared = AdManager()

    @Published var isAdLoaded = false
    @Published var isAdPresenting = false

    private var interstitialAd: InterstitialAd?
    private var isInitialized = false
    // Using TEST ad unit ID for App Store submission
    private var adUnitID = "ca-app-pub-3940256099942544/4411468910" // TEST AD UNIT ID

    override init() {
        super.init()
        // Don't initialize immediately - wait for explicit call
    }

    func initializeAdSDK() {
        guard !isInitialized else { return }

        // Check if GADApplicationIdentifier is configured
        print("📱 Bundle info keys: \(Bundle.main.infoDictionary?.keys.sorted() ?? [])")
        if let appId = Bundle.main.object(forInfoDictionaryKey: "GADApplicationIdentifier") as? String,
           !appId.isEmpty {
            print("🚀 Initializing AdMob SDK with App ID: \(appId)")
        } else {
            print("⚠️ GADApplicationIdentifier not found in Info.plist")
            print("📱 Full bundle info: \(Bundle.main.infoDictionary ?? [:])")
        }

        isInitialized = true

        // Configure test device identifiers first
        #if DEBUG
        MobileAds.shared.requestConfiguration.testDeviceIdentifiers = [
            "kGADSimulatorID"
        ]
        print("🧪 Test device identifiers configured")
        #endif

        // Start AdMob SDK
        MobileAds.shared.start { [weak self] status in
            DispatchQueue.main.async {
                print("📱 AdMob SDK initialized successfully")
                print("📱 Initialization status: \(status.adapterStatusesByClassName)")
                self?.loadInterstitialAd()
            }
        }
    }

    func loadInterstitialAd() {
        guard isInitialized else {
            initializeAdSDK()
            return
        }

        let request = Request()

        InterstitialAd.load(with: adUnitID, request: request) { [weak self] ad, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Failed to load ad: \(error.localizedDescription)")
                    self?.isAdLoaded = false
                    return
                }

                self?.interstitialAd = ad
                self?.interstitialAd?.fullScreenContentDelegate = self
                self?.isAdLoaded = true
                print("✅ Real AdMob test ad loaded successfully")

                // Execute pending ad request if any
                if let pendingRequest = self?.pendingAdRequest {
                    self?.pendingAdRequest = nil
                    pendingRequest()
                }
            }
        }
    }

    private var pendingAdRequest: (() -> Void)?

    func presentInterstitialAd(from viewController: UIViewController, completion: @escaping () -> Void) {
        // Initialize SDK if not already done - but only when actually needed
        if !isInitialized {
            print("🚀 Initializing AdMob only when needed...")
            pendingAdRequest = {
                self.actuallyPresentAd(from: viewController, completion: completion, retryCount: 0)
            }
            initializeAdSDK()
            return
        }

        actuallyPresentAd(from: viewController, completion: completion, retryCount: 0)
    }

    private func actuallyPresentAd(from viewController: UIViewController, completion: @escaping () -> Void, retryCount: Int) {
        guard let interstitialAd = interstitialAd else {
            print("⚠️ Ad not ready, proceeding without ad")
            completion()
            return
        }

        // Check if view controller is in a valid state to present
        guard viewController.presentedViewController == nil &&
              viewController.isBeingPresented == false &&
              viewController.isBeingDismissed == false &&
              viewController.view.window != nil &&
              viewController.view.window?.isKeyWindow == true else {
            if retryCount < 5 {
                print("⚠️ View controller not ready to present ad, retrying after delay (attempt \(retryCount + 1)/5)")
                print("   - presentedViewController: \(viewController.presentedViewController != nil)")
                print("   - isBeingPresented: \(viewController.isBeingPresented)")
                print("   - isBeingDismissed: \(viewController.isBeingDismissed)")
                print("   - hasWindow: \(viewController.view.window != nil)")
                print("   - isKeyWindow: \(viewController.view.window?.isKeyWindow == true)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    self.actuallyPresentAd(from: viewController, completion: completion, retryCount: retryCount + 1)
                }
            } else {
                print("⚠️ Failed to present ad after 5 attempts, proceeding without ad")
                completion()
            }
            return
        }

        print("✅ Presenting AdMob interstitial ad")
        isAdPresenting = true
        interstitialAd.present(from: viewController)
        self.adDismissalCompletion = completion
    }

    private var adDismissalCompletion: (() -> Void)?
}

// MARK: - FullScreenContentDelegate
extension AdManager: FullScreenContentDelegate {
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("❌ Ad failed to present: \(error.localizedDescription)")
        isAdPresenting = false
        adDismissalCompletion?()
        adDismissalCompletion = nil
        loadInterstitialAd()
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("✅ Real AdMob ad dismissed")
        isAdPresenting = false
        adDismissalCompletion?()
        adDismissalCompletion = nil
        loadInterstitialAd()
    }
}