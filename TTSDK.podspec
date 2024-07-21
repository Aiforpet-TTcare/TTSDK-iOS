Pod::Spec.new do |spec|
  spec.name         = "TTSDK"
  spec.version      = "1.5.0"
  spec.summary      = "AI module for diagnosing dogs (eyes, teeth, skin, joints) and cats (eyes, teeth)."
  spec.description  = <<-DESC
TTSDK is a powerful AI module designed to assist veterinarians and pet owners in diagnosing common health issues in dogs and cats. The module specializes in:

- Dogs: Eyes, Teeth, Skin, Joints
- Cats: Eyes, Teeth

By leveraging advanced machine learning algorithms, TTSDK provides accurate and fast diagnostics to help ensure the health and well-being of pets. 
                   DESC
  spec.homepage     = "https://www.aiforpet.com/"
  spec.license      = { :type => 'Data and API Subscription License', :text => 'This library requires a subscription license to access the TTSDK service. Please refer to the service documentation for more details.' }
  spec.author       = { "hjlee" => "hjlee@aiforpet.com" }
  spec.platform     = :ios, "12.0"
  spec.source       = { :git => "https://github.com/Aiforpet-TTcare/TTSDK-iOS.git", :tag => "#{spec.version}" }
  spec.vendored_frameworks = 'TTSDK.xcframework'
  spec.dependency "TensorFlowLiteSwift", "~> 2.14.0"
  spec.swift_version    = '5.5'
end
