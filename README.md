# GolfSwingTrainer

## Overview

**GolfSwingTrainer** is an innovative iOS and watchOS app designed to help golfers improve their swing and assist trainers in tracking their trainees' progress. The app utilizes the sensor capabilities of Apple Watch to collect detailed swing data during sessions and sends this data to the paired iOS device for advanced analytics and visualization. The app incorporates Core Data for local data management and Firebase Cloud for seamless cloud synchronization, ensuring user data is securely stored and accessible across devices.

## Features

- **Real-time Swing Analysis:** Collects and analyzes swing data using watchOS sensors.
- **Data Synchronization:** Automatically syncs collected data with the paired iOS device.
- **Analytics Dashboard:** Displays detailed swing metrics and visualizations on the iOS app.
- **Trainer-Trainee Integration:** Allows trainers to monitor trainees' progress over time.
- **Cloud Backup:** Securely stores user data in Firebase Cloud.
- **Offline Functionality:** Supports offline data recording with synchronization once reconnected.

## Requirements

- **iOS Version:** 17.0 or later
- **watchOS Version:** 10.0 or later
- **Development Environment:** Xcode 15.0 or later
- **Dependencies:**
  - Firebase SDK
  - Core Data
  - SwiftUI

## Installation

### Prerequisites

1. Install the latest version of [Xcode](https://developer.apple.com/xcode/).
2. Ensure your Mac is running macOS Ventura or later.
3. Create a Firebase project and download the `GoogleService-Info.plist` file for iOS configuration.

### Steps to Set Up

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/HarryLiu4154/GolfSwingTrainer.git
   cd GolfSwingTrainer
   ```

2. **Open the Project in Xcode:**
   - Double-click the `GolfSwingTraining.xcodeproj` file to open the project in Xcode.

3. **Install Dependencies:**
   - Ensure CocoaPods is installed:
     ```bash
     sudo gem install cocoapods
     ```
   - Navigate to the project directory and install pods:
     ```bash
     pod install
     ```

4. **Add Firebase Configuration:**
   - Place the `GoogleService-Info.plist` file in the root directory of the iOS target within Xcode.

5. **Select Target Devices:**
   - In Xcode, select the `GolfSwingTrainer` project.
   - Choose the desired scheme (iOS or watchOS) for building and testing.

6. **Build and Run the App:**
   - Connect your iPhone and Apple Watch to your Mac.
   - Select your iPhone as the run destination for the iOS target and your Apple Watch for the watchOS target.
   - Press `Cmd + R` to build and run the app on your devices.

### Testing the App

1. **Set Up a Test User:**
   - Launch the app on your iPhone and sign up using the test credentials.
   - Ensure your Apple Watch is paired with the same iPhone.

2. **Start a Swing Session:**
   - Open the app on your Apple Watch.
   - Begin a swing session to collect data.

3. **Review Analytics:**
   - Open the iOS app to view swing metrics and analytics in real time.

## Contribution

We welcome contributions to improve GolfSwingTraining! Please follow these steps:

1. Fork the repository.
2. Create a new branch for your feature or bug fix:
   ```bash
   git checkout -b feature-name
   ```
3. Commit your changes and push to your fork:
   ```bash
   git commit -m "Add feature or fix bug"
   git push origin feature-name
   ```
4. Submit a pull request.

## License

GolfSwingTrainer is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.


