# Store Release Checklist (Apple + Google Play)

This project is now prepared to the point where publishing is blocked only by your store accounts/credentials and final store metadata.

## 1) Backend Production
- Deploy backend with `https` (required for store builds).
- Set a production secret for auth tokens (`Auth:Secret`).
- Keep stable API base URL, e.g. `https://api.yourdomain.com`.
- Configure Stripe in production:
  - `Payments:Stripe:SecretKey`
  - `Payments:Stripe:WebhookSecret`
- Expose webhook endpoint and register in Stripe Dashboard:
  - `POST https://api.yourdomain.com/api/payments/webhook/stripe`

## 2) App Identity and Version
- Android package id: `com.mauricio.garagesale`
- iOS bundle id: `com.mauricio.garagesale`
- Update app version in `pubspec.yaml` (`version: x.y.z+build`).

## 3) Android Signing
1. Generate an upload keystore.
2. Copy `android/key.properties.example` to `android/key.properties`.
3. Fill real values (`storeFile`, `storePassword`, `keyAlias`, `keyPassword`).
4. Keep keystore outside git (`/keystore` is ignored).

## 4) iOS Signing
- Open `ios/Runner.xcworkspace` in Xcode.
- Configure Team, Bundle Identifier, Signing Certificate and Provisioning Profile.
- Ensure Automatic Signing or valid manual profiles for Release.

## 5) Maps Key
- Set production Google Maps key in:
  - `android/app/src/main/res/values/google_maps_api.xml`
- If using iOS native maps key restrictions, configure it in your Google Cloud console.

## 6) Build Commands
- Android AAB:
  - `./scripts/build_android_release.sh https://api.yourdomain.com`
- iOS IPA:
  - `./scripts/build_ios_release.sh https://api.yourdomain.com`

## 7) Mandatory Store Assets/Metadata (manual in consoles)
- App name, subtitle/short description, long description.
- Privacy policy URL and support URL.
- Screenshots for required device sizes.
- App icon and category.
- Content rating and data safety/privacy questionnaire.

## 8) Final QA Before Submit
- Fresh install + login/register + session restore after app restart.
- Publish/edit/delete listing.
- Paid event flow:
  - Create checkout for event publication.
  - Complete payment on Stripe Checkout.
  - Confirm webhook updates payment to `paid`.
- Favorites sync.
- Messages sync.
- Job application sync.
- Logout and re-login.
- Test on real Android + iPhone device.

## 9) Submission
- Upload `.aab` to Google Play (Internal testing first).
- Upload `.ipa` to App Store Connect (TestFlight first).
- Approve compliance forms and submit for review.
