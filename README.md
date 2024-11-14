AgriBazar 🌾 - Connecting Farmers and Buyers for Transparent Crop Trading

AgriBazar is a mobile application built to bridge the gap between farmers and buyers, enabling them to connect, communicate, and conduct crop trading transparently. The app empowers both parties to negotiate, agree, and finalize transactions in a secure and user-friendly environment. Future updates aim to provide features like legal contracts, location tracking, payment gateway integration, notifications, and real-time crop pricing.

📱 Features
Current Features
User Authentication

Secure Login and Registration: Users can securely log in and register using Firebase Authentication.
Role-Based Profiles: Farmers and buyers have access to tailored features specific to their roles.

Crop Listings :

Create and Browse Listings: Farmers can post crop listings with detailed information, while buyers can search and filter listings by type, crop name.
Real-Time Updates: Firebase Firestore provides real-time updates for all crop listings.

Direct Messaging :

Built-in Chat Feature: Buyers and farmers can directly communicate through a secure, private chat feature to negotiate deals and discuss terms.
Data Security: Chat history is stored securely, accessible only by the users involved in the conversation.

Planned Features

1) Contract Farming :

Legal Agreements: The app will allow both parties to create and sign legal contracts for transactions, enhancing trust and transparency.
Contract Management: Future updates will include features for tracking and managing contract statuses, helping both parties stay informed and organized.

2) Location Tracking :

Current Location Display: Farmers and buyers can view each other's location to facilitate logistics and track delivery status.
Visited Location History: Future updates will include a timeline view of visited locations, allowing transparent tracking of routes and delivery progress.

3) Payment Gateway Integration :

Secure Payments: Planned integration of a payment gateway will allow buyers to securely pay for crops directly through the app, facilitating seamless transactions.
Payment Tracking: Both parties will be able to track payment statuses for enhanced clarity and record-keeping.

4) Notifications and Alerts :

Real-Time Alerts: Future notification features will inform users about new messages, contract status updates, and important crop listings.
Customizable Notifications: Users will have the option to manage notification settings according to their preferences.

5) Real-Time Government Crop Pricing :

Live Price Updates: The app will incorporate real-time government crop prices, giving farmers and buyers transparent information for fair trading.
Market Insights: This feature will help users make informed decisions based on the latest market prices.

🛠️ Tech Stack :
Frontend: Flutter for cross-platform mobile app development.
Backend: Firebase (Authentication, Firestore for real-time data storage, Cloud Messaging for notifications, Firebase Storage for media Storage).
Environment Configuration: Using flutter_dotenv to manage sensitive data securely.
Future Integrations: Planned support for payment gateways and location tracking through Google Maps API.

User Authentication Screenshot :
![IMG_20241114_202929](https://github.com/user-attachments/assets/1dc6b34e-3ebb-40ea-a57f-76c2495ddf48)


Farmers UI Screenshot:
![IMG_20241114_202821](https://github.com/user-attachments/assets/84a18e89-50a4-4e56-99cf-570ea465e683)

Buyer UI Screenshot:
![IMG_20241114_220358](https://github.com/user-attachments/assets/dba6a41e-1fac-49e2-aaf8-ee5b3da81a95)

🚀 Getting Started

Prerequisites

Flutter SDK
Firebase Project with necessary configurations
Installation

Clone the Repository

bash
Copy code :
git clone https://github.com/username/agribazar.git

cd agribazar

Environment Setup

Add Firebase configuration files (google-services.json for Android and GoogleService-Info.plist for iOS).
Set up a .env file to securely manage API keys:
env

Copy code
WEB_API_KEY=your_web_api_key
ANDROID_API_KEY=your_android_api_key
IOS_API_KEY=your_ios_api_key
# other sensitive keys
Install Dependencies

bash
Copy code
flutter pub get
Run the App

bash
Copy code
flutter run
👥 Contributing
We welcome contributions to help bring AgriBazar’s planned features to life! To contribute:

Fork the repository and create a new branch for your feature.
Submit a pull request with a detailed description of your work.
Ensure all tests are passing before submitting the PR.
