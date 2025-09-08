# CI/CD Infrastructure Setup

This repository now includes GitHub Actions workflows for continuous integration and deployment.

## Problem Solved

The CI/CD pipeline was failing due to a Dart SDK version mismatch:
- **Required**: Dart SDK ^3.8.1 (as specified in pubspec.yaml)
- **Available in CI**: Dart SDK 3.5.3 
- **Solution**: Use Flutter beta channel which includes newer Dart versions

## Workflow Configuration

### Main CI/CD Pipeline (`.github/workflows/ci.yml`)

- **Triggers**: 
  - Push to `main` or `develop` branches
  - Pull requests to `main` or `develop` branches

- **Flutter Setup**:
  - Channel: `beta` (to get Dart 3.8.1+ support)
  - Version: `latest` (automatically gets the newest beta)
  - Caching: Enabled for faster builds

- **Pipeline Steps**:
  1. **Test Job**:
     - Checkout code
     - Setup Flutter (beta channel)
     - Verify Flutter/Dart versions
     - Install dependencies (`flutter pub get`)
     - Analyze code (`flutter analyze`)
     - Run tests (`flutter test`)
     - Build APK for Android
     - Build web assets

  2. **Deploy Job** (only on main branch):
     - Setup Flutter
     - Build web assets for production
     - Deploy to GitHub Pages

## Why Beta Channel?

The stable Flutter channel (as of the time this was implemented) includes Dart SDK versions around 3.5.x, which doesn't meet the ^3.8.1 requirement. The beta channel provides access to newer Dart SDK versions that satisfy this constraint.

## Alternative Solutions

If the beta channel becomes unstable or if you prefer a more conservative approach:

1. **Use Stable Channel**: Change the pubspec.yaml Dart SDK requirement to `^3.5.0`
2. **Use Master Channel**: For bleeding-edge Dart features (not recommended for production)
3. **Pin Specific Version**: Use a specific Flutter version known to include Dart 3.8.1+

## Monitoring

Check the Actions tab in GitHub to monitor workflow runs and ensure:
- Dependencies resolve successfully
- All tests pass
- Builds complete without errors
- Deployments succeed (for main branch)