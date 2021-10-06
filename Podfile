# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

workspace 'More Dependency'

project 'More Dependency'

def common_pods_for_target
  
  
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  # Pods for Corenroll
  
  #   Material Design TextFields
  pod 'MaterialComponents/TextControls+FilledTextAreas'
  pod 'MaterialComponents/TextControls+FilledTextFields'
  pod 'MaterialComponents/TextControls+OutlinedTextAreas'
  pod 'MaterialComponents/TextControls+OutlinedTextFields'
  
  pod 'MaterialComponents/TextControls+FilledTextAreasTheming'
  pod 'MaterialComponents/TextControls+FilledTextFieldsTheming'
  pod 'MaterialComponents/TextControls+OutlinedTextAreasTheming'
  pod 'MaterialComponents/TextControls+OutlinedTextFieldsTheming'
  
  pod 'MaterialComponents/TextFields'
  pod 'MaterialComponents/NavigationDrawer'
  pod 'IQKeyboardManagerSwift' # The MIT License (MIT)
  pod 'SVProgressHUD'
  
  pod 'RealmSwift' #, '~> 4.4.1' # Database
  
  pod 'Alamofire' # The MIT License (MIT)
  pod 'ObjectMapper' # The MIT License (MIT)
  pod 'SwiftyJSON'
  
  ### BubbleShowCase-iOS is available under the MIT license. See the LICENSE file for more info.
  # pod 'BubbleShowCase' ## Used in external libraries direct copy to project.
  
  # add the Firebase pod for Google Analytics
  pod 'Firebase/Analytics'
  pod 'Firebase/Messaging'
  pod 'Firebase/Crashlytics'

  # add pods for any other desired Firebase products
  # https://firebase.google.com/docs/ios/setup#available-pods
  
  
  #  pod 'Gridicons' # For Aztec
  pod 'Gridicons' #, :podspec => 'https://raw.github.com/Automattic/Gridicons-iOS/develop/Gridicons.podspec'
  
  
end

target 'More Dependency' do

  # Pods for Corenroll Group
  
  common_pods_for_target

end

target 'More DependencyTests' do

  # Pods for Corenroll Group
  
  common_pods_for_target

end


#post_install do |installer|
#  installer.pods_project.build_configurations.each do |config|
#    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
#  end
#end
