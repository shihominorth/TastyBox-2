# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'TastyBox-2' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!
  
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
pod 'GoogleMLKit/ImageLabeling', '2.3.0'

# for reactive-programming
pod 'RxSwift'
pod 'RxCocoa'
pod 'Action'
pod 'RxTimelane'
pod 'RxDataSources'

pod 'DifferenceKit'

# RxTest and RxBlocking make the most sense in the context of unit/integration tests
pod 'RxBlocking'
# pod RxTest cause dyld: Library not loaded: @rpath/XCTest.framework/XCTest

pod 'RxTimelane'

#pods for Google sign in
pod 'GoogleSignIn'

# pods for facebook sign in
pod 'FBSDKCoreKit'
pod 'FBSDKLoginKit'


# edit
pod 'RSKImageCropper'
pod "PryntTrimmerView"

# Alert 
pod 'SCLAlertView'
pod 'SwiftMessages'


#Lottie
pod 'lottie-ios'

#Image
pod 'Kingfisher'
pod 'SkeletonView'

#API
pod 'Alamofire'

#json
#pod 'SwiftyJSON'

#Google Spread Sheet
pod 'GoogleAPIClientForREST/Sheets'
pod 'GoogleAPIClientForREST/Drive'

require 'open3'
Open3.capture3("ruby update_run_script_setting.rb --no-only --project=TastyBox-2.xcodeproj --target=TastyBox-2 --phases='[CP] Embed Pods Frameworks','[CP] Copy Pods Resources','Copy Carthage Framework'")

end
