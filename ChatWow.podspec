Pod::Spec.new do |s|
  s.name         = "ChatWow"
  s.version      = "0.1"
  s.summary      = "Chat UI framework for iOS."
  s.description  = <<-DESC
Provides all the basic UI elements necessary to implement a chat interface.
                   DESC

  s.homepage     = "https://github.com/LooponAB/ChatWow"
  s.license      = { :type => "BSD", :file => "LICENSE" }
  s.author       = { "Loopon AB" => "support@loopon.com" }
  s.platform     = :ios, "9.0"

  s.source       = { :git => "https://github.com/LooponAB/ChatWow.git", :tag => "#{s.version}" }

  s.source_files  = "ChatWow", "ChatWow/*.{swift,h,xib}" 

  s.resources = "ChatWow/*.xcassets"

end
