# AdMob Integration Setup Guide 📱💰

## What I've Implemented

✅ **AdManager Service**: Handles interstitial ad loading and presentation
✅ **LetterSentConfirmationView Integration**: Shows ad after user clicks "Continue"
✅ **ViewController Helper**: Enables ad presentation from SwiftUI
✅ **Configuration Files**: AdMob plist configuration ready to add

## Required Setup Steps

### 1. 🔧 Add Google AdMob SDK to Your Xcode Project

**Option A: Swift Package Manager (Recommended)**
1. Open your Xcode project
2. Go to **File → Add Package Dependencies**
3. Enter URL: `https://github.com/googleads/swift-package-manager-google-mobile-ads.git`
4. Click **Add Package**
5. Select **GoogleMobileAds** and click **Add Package**

**Option B: CocoaPods**
1. Create a `Podfile` in your project root:
```ruby
platform :ios, '12.0'
use_frameworks!

target 'futureMe' do
  pod 'Google-Mobile-Ads-SDK'
end
```
2. Run `pod install`
3. Use the `.xcworkspace` file going forward

### 2. 📋 Update Info.plist Configuration

1. In Xcode, find your **Info.plist** file (usually in the project navigator)
2. Right-click and choose **Open As → Source Code**
3. Add this content inside the `<dict>` tags:

```xml
<!-- Replace with your actual AdMob App ID when you get it -->
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-3940256099942544~1458002511</string>

<!-- Add SKAdNetwork identifiers (copy from AdMobConfig.plist I created) -->
<key>SKAdNetworkItems</key>
<array>
    <!-- Copy the entire SKAdNetworkItems array from AdMobConfig.plist -->
</array>
```

### 3. 🏢 Create Google AdMob Account

1. **Go to**: [https://admob.google.com](https://admob.google.com)
2. **Sign in** with your Google account
3. **Click** "Get Started"
4. **Choose** "I develop apps" if asked

### 4. 📱 Register Your App

1. In AdMob dashboard, click **"Apps"** → **"Add App"**
2. **Select** "iOS"
3. **Choose** "App is published on app store" (if published) or "App is not published"
4. **Enter** your app name: "Future Me"
5. **Select** your app from App Store (if published) or enter details manually
6. **Click** "Add App"

### 5. 🎯 Create Ad Units

1. **Click** on your newly created app
2. **Click** "Ad Units" → **"Add Ad Unit"**
3. **Select** "Interstitial"
4. **Name**: "Letter Sent Interstitial"
5. **Click** "Create Ad Unit"
6. **Copy the Ad Unit ID** (starts with `ca-app-pub-`)

### 6. 🔄 Update Your Code

**Replace Test IDs with Real IDs:**

1. **Open** `AdManager.swift`
2. **Replace** the test Ad Unit ID:
```swift
// Replace this line:
private var adUnitID = "ca-app-pub-3940256099942544/4411468910" // Test Ad Unit ID

// With your real Ad Unit ID:
private var adUnitID = "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX" // Your Ad Unit ID
```

3. **Open** your **Info.plist**
4. **Replace** the test App ID:
```xml
<!-- Replace this -->
<string>ca-app-pub-3940256099942544~1458002511</string>
<!-- With your real App ID -->
<string>ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX</string>
```

### 7. 🧪 Testing

**Test with Test IDs First:**
- The code is already set up with test IDs
- Build and run your app
- Write a letter and tap "Continue"
- You should see a test interstitial ad

**Test with Real IDs:**
- After replacing with real IDs, test again
- **Note**: Real ads may not show immediately in development
- Use **AdMob test devices** for consistent testing

### 8. 🔍 Add Test Device (Optional but Recommended)

1. **Find your device ID**: Check Xcode console for "Request an interstitial ad for device"
2. **Add to AdManager.swift**:
```swift
GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [
    GADSimulatorID,
    "YOUR_DEVICE_ID_HERE" // Add your device ID
]
```

### 9. 📊 App Store Configuration

**When submitting to App Store:**

1. **Add** App Transport Security exception if needed:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

2. **Complete** AdMob app review process
3. **Enable** your ad units in AdMob dashboard

## 🎯 How It Works

1. **User writes letter** and taps "Schedule"
2. **Confirmation screen** appears with success message
3. **User taps "Continue"**
4. **Interstitial ad displays** (full screen)
5. **After ad closes**, user returns to home screen
6. **New ad loads** automatically for next time

## 🔧 Troubleshooting

**No ads showing?**
- Check internet connection
- Verify Ad Unit IDs are correct
- Check AdMob dashboard for ad fill rates
- Enable test mode with test device IDs

**App crashes?**
- Make sure Google AdMob SDK is properly added
- Check that Info.plist has correct App ID
- Verify all imports are correct

**Ads not loading fast enough?**
- AdManager preloads ads in the background
- Consider adding loading indicators
- Implement fallback behavior for slow networks

## 💰 Monetization Tips

1. **Don't show ads too frequently** - Users will uninstall
2. **Consider ad frequency capping** in AdMob dashboard
3. **Monitor user feedback** about ad experience
4. **Test different ad placements** for better performance
5. **Use mediation** for higher fill rates (advanced)

## 📈 Next Steps

1. **Complete the setup steps above**
2. **Test thoroughly** with test IDs
3. **Replace with real IDs** when ready
4. **Submit app** for review
5. **Monitor performance** in AdMob dashboard

## 🚀 You're All Set!

Your Future Me app now has professional advertising integration! The ads will show after users schedule their letters, providing a natural break point that doesn't interrupt the core user experience.

**Questions?** Check AdMob documentation or reach out for help!