# GitHub Secrets Configuration

This document outlines the secrets required for the CI/CD pipeline to function properly.

## Required Secrets

### Google Services Configuration

#### GOOGLE_SERVICES_JSON_BASE64 (Required for Android builds)
- **Description**: Base64-encoded content of `android/app/google-services.json`
- **How to generate**:
  ```bash
  base64 -w0 android/app/google-services.json
  ```
- **Used in**: Android build jobs to configure Firebase services

#### GOOGLE_SERVICE_INFO_PLIST_BASE64 (Required for iOS/macOS builds)
- **Description**: Base64-encoded content of `ios/Runner/GoogleService-Info.plist` (same file used for macOS)
- **How to generate**:
  ```bash
  base64 -w0 ios/Runner/GoogleService-Info.plist
  ```
- **Used in**: iOS and macOS build jobs to configure Firebase services

### Android Signing (Optional - only needed for release builds)

#### ANDROID_KEYSTORE_BASE64
- **Description**: Base64-encoded Android keystore file
- **How to generate**:
  ```bash
  base64 -w0 path/to/your/keystore.jks
  ```

#### ANDROID_KEYSTORE_PASSWORD
- **Description**: Password for the Android keystore

#### ANDROID_KEY_ALIAS
- **Description**: Key alias used in the keystore

#### ANDROID_KEY_PASSWORD
- **Description**: Password for the specific key in the keystore

### iOS Signing (Optional - only needed for release builds)

#### IOS_CERTIFICATE_BASE64
- **Description**: Base64-encoded iOS distribution certificate (.p12 file)
- **How to generate**:
  ```bash
  base64 -w0 path/to/your/certificate.p12
  ```

#### IOS_CERTIFICATE_PASSWORD
- **Description**: Password for the iOS certificate

#### IOS_PROVISIONING_PROFILE_BASE64
- **Description**: Base64-encoded iOS provisioning profile
- **How to generate**:
  ```bash
  base64 -w0 path/to/your/profile.mobileprovision
  ```

### Firebase Deployment (Optional - only needed for web deployment)

#### FIREBASE_SERVICE_ACCOUNT
- **Description**: Firebase service account JSON for deployment
- **How to generate**: Download from Firebase Console → Project Settings → Service Accounts

#### FIREBASE_PROJECT_ID
- **Description**: Your Firebase project ID
- **Where to find**: Firebase Console → Project Settings → General

## Setup Instructions

1. **Navigate to Repository Settings**:
   - Go to your GitHub repository
   - Click on "Settings" tab
   - Select "Secrets and variables" → "Actions"

2. **Add Required Secrets**:
   - Click "New repository secret"
   - Add each secret with the exact name listed above
   - Paste the corresponding value

3. **Minimum Required for Basic Functionality**:
   - `GOOGLE_SERVICES_JSON_BASE64` (for Android builds)
   - `GOOGLE_SERVICE_INFO_PLIST_BASE64` (for iOS/macOS builds)

4. **Optional Secrets**:
   - Android/iOS signing secrets are only needed if you want to create signed release builds
   - Firebase deployment secrets are only needed if you want automatic web deployment

## Security Notes

- **Never commit** the actual `google-services.json` or `GoogleService-Info.plist` files to your repository
- **Never commit** signing certificates or keys to your repository
- These files contain sensitive configuration that should only exist as GitHub secrets
- The workflow will safely decode and place these files during the build process
- Files are automatically cleaned up after each build job completes

## Troubleshooting

### Build fails with "File google-services.json is missing"
- Ensure `GOOGLE_SERVICES_JSON_BASE64` secret is set correctly
- Verify the base64 encoding was done without line breaks (`-w0` flag)
- Check that the original file path was `android/app/google-services.json`

### iOS build fails with Firebase configuration errors
- Ensure `GOOGLE_SERVICE_INFO_PLIST_BASE64` secret is set correctly
- Verify the base64 encoding was done without line breaks
- Check that the original file path was `ios/Runner/GoogleService-Info.plist`

### Workflow shows "Warning: SECRET_NAME secret not found"
- This is expected behavior when secrets are not configured
- Firebase features may not work, but the build will still succeed
- Add the missing secret to resolve the warning
