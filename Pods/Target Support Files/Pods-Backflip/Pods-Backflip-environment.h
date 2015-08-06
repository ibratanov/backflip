
// To check if a library is compiled with CocoaPods you
// can use the `COCOAPODS` macro definition which is
// defined in the xcconfigs so it is available in
// headers also when they are imported in the client
// project.


// Mixpanel
#define COCOAPODS_POD_AVAILABLE_Mixpanel
#define COCOAPODS_VERSION_MAJOR_Mixpanel 2
#define COCOAPODS_VERSION_MINOR_Mixpanel 8
#define COCOAPODS_VERSION_PATCH_Mixpanel 2

// Mixpanel/Mixpanel
#define COCOAPODS_POD_AVAILABLE_Mixpanel_Mixpanel
#define COCOAPODS_VERSION_MAJOR_Mixpanel_Mixpanel 2
#define COCOAPODS_VERSION_MINOR_Mixpanel_Mixpanel 8
#define COCOAPODS_VERSION_PATCH_Mixpanel_Mixpanel 2

// Debug build configuration
#ifdef DEBUG

  // Reveal-iOS-SDK
  #define COCOAPODS_POD_AVAILABLE_Reveal_iOS_SDK
  #define COCOAPODS_VERSION_MAJOR_Reveal_iOS_SDK 1
  #define COCOAPODS_VERSION_MINOR_Reveal_iOS_SDK 5
  #define COCOAPODS_VERSION_PATCH_Reveal_iOS_SDK 1

#endif
