# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'KerdoIndexSPORT' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for KedroIndex

pod 'Charts'
pod 'IQKeyboardManagerSwift', '6.3.0'
pod 'mailcore2-ios'
pod 'GoogleSignIn'
pod 'ReachabilitySwift'
pod 'FirebaseAuth'
pod 'FirebaseFirestore'
pod 'FirebaseDatabase'

end

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
               end
          end
   end
end
