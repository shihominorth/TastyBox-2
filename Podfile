# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'TastyBox-2' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for TastyBox-2
  post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    end
  end
  #Firebase

pod 'Firebase/Analytics'
pod 'Firebase/DynamicLinks'
pod 'Firebase/Auth'
pod 'Firebase/Firestore'
pod 'Firebase/Storage'
pod 'Firebase/Core'


# for reactive-programming
pod 'RxSwift'
pod 'RxCocoa'
pod 'Action'
pod 'DifferenceKit'

# RxTest and RxBlocking make the most sense in the context of unit/integration tests
pod 'RxBlocking'
# pod RxTest cause dyld: Library not loaded: @rpath/XCTest.framework/XCTest

pod 'RxTimelane'

#pods for Google sign in
pod 'GoogleSignIn'

# pods for facebook sign in
pod 'FBSDKLoginKit'


# edit image 
pod 'RSKImageCropper'

# Alert 
pod 'SCLAlertView'

#Lottie
pod 'lottie-ios'

end
