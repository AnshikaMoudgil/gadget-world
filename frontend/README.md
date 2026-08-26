# Gadget World

A modern Flutter-based gadget store application. 

## Current Progress

The UI implementation is well underway, featuring a comprehensive set of screens including:
- **Authentication**: Login and Signup screens
- **Onboarding**: Splash and Onboarding flows
- **Main Navigation**: Home screen, Main screen with bottom navigation, and Profile screen
- **Shopping**: Product Details, Cart, Category specific screens (Mobiles, Laptops)
- **Search**: Search Results screen for finding gadgets

## Setup Instructions

To get this project up and running on your local machine, follow these steps:

1. **Install Flutter**: Ensure you have the Flutter SDK installed. If not, follow the guide at [flutter.dev](https://docs.flutter.dev/get-started/install).
2. **Clone the Repository**:
   ```bash
   git clone https://github.com/AnshikaMoudgil/Tensorik-GadgetStore.git
   ```
3. **Navigate to the Project Directory**:
   ```bash
   cd Tensorik-GadgetStore
   ```
4. **Environment Variables**:
   Create a `.env` file in the root of the `frontend` directory and add the following keys (including your production `BACKEND_URL` when deployed to Render):
   ```env
   SUPABASE_URL=your_supabase_url
   SUPABASE_PUBLISHABLE_KEY=your_supabase_publishable_key
   BACKEND_URL=https://your-backend-url.onrender.com
   ```
5. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

## Run Instructions

1. **Start an Emulator or Connect a Device**: Ensure you have a device connected or an emulator running. You can check connected devices with:
   ```bash
   flutter devices
   ```
2. **Run the App**:
   ```bash
   flutter run
   ```
