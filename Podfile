#
# Podfile
#

source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '12.0'
use_frameworks!


# Pod definitions

def basic_pods

    pod 'SwiftyJSON'
    pod 'CrossroadRegex'

end

def test_pods

    pod 'SwiftyJSON'
    pod 'CrossroadRegex'

end


# Target Definitions

target 'Weather 5D' do
	basic_pods
end

target 'Weather 5DTests' do
    test_pods
end


post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4.2'
        end
    end
end

