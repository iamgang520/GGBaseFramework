#
# Be sure to run `pod lib lint CGBlankPage.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GGBaseFramework'

  s.version          = '0.0.3'

  s.summary          = '我的基础库'

  s.description      = <<-DESC
	我的基础库-主要是UI库
                       DESC

  s.homepage         = 'http://www.iamgang.com'

  s.license          = { :type => 'MIT', :text => <<-LICENSE
                        Copyright 2022
                         LICENSE
                      }

  s.author           = { 'iamgang' => '5391519@qq.com' }

  s.source           = { :git => 'https://github.com/iamgang520/GGBaseFramework.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'

  s.prefix_header_file = 'GGBaseFramework/BaseFramework/BaseFrameworkPrefixHeader.pch'

  s.dependency 'JKCategories'
  s.dependency 'MJExtension'
  s.dependency 'SDWebImage'

  s.subspec 'Config' do |ss|
    ss.subspec "Constant" do |sss|
      sss.source_files = 'GGBaseFramework/BaseFramework/Config/BaseConstant.{h,m}'
    end
    ss.subspec "LogConfig" do |sss|
      sss.source_files = 'GGBaseFramework/BaseFramework/Config/BaseLogConfig.{h,m}'
    end
    ss.subspec "UIConfig" do |sss|
      sss.dependency 'GGBaseFramework/Config/LogConfig'
      sss.source_files = 'GGBaseFramework/BaseFramework/Config/BaseUIConfig.{h,m}'
    end
  end

  s.subspec 'UIKit' do |ss|
    ss.dependency 'GGBaseFramework/Config'

    ss.subspec "GGProgressHUD" do |sss|
      sss.dependency 'LCProgressHUD'
      sss.source_files = 'GGBaseFramework/BaseFramework/UIKit/GGProgressHUD/*.{h,m}'
    end
    ss.subspec "GANGActionSheet" do |sss|
      sss.source_files = 'GGBaseFramework/BaseFramework/UIKit/GANGActionSheet/*.{h,m}'
    end
    ss.subspec "GGCircleProgressView" do |sss|
      sss.source_files = 'GGBaseFramework/BaseFramework/UIKit/GGCircleProgressView/*.{h,m}'
    end
    ss.subspec "GANGAlertView" do |sss|
      sss.source_files = 'GGBaseFramework/BaseFramework/UIKit/GANGAlertView/*.{h,m}'
    end
    ss.subspec "ScaleFontView" do |sss|
      sss.source_files = 'GGBaseFramework/BaseFramework/UIKit/ScaleFontView/*.{h,m}'
    end
    ss.subspec "GGToast" do |sss|
      sss.source_files = 'GGBaseFramework/BaseFramework/UIKit/GGToast/*.{h,m}'
    end
  end

  s.subspec 'Network' do |ss|
    ss.dependency 'GGBaseFramework/Config/LogConfig'
    ss.dependency 'GGBaseFramework/UIKit'
    ss.dependency 'AFNetworking'

    ss.subspec "Tools" do |sss|
      sss.source_files = 'GGBaseFramework/BaseFramework/Network/Tools/**/*.{h,m}'
    end
    
    ss.source_files = 'GGBaseFramework/BaseFramework/Network/*.{h,m}'
  end

  s.subspec "Tools" do |ss|
    ss.dependency 'GGBaseFramework/UIKit'
    ss.dependency 'GGBaseFramework/Network'

    ss.subspec "VideoTools" do |sss|
      sss.source_files = 'GGBaseFramework/BaseFramework/Tools/VideoTools/*.{h,m}'
    end
    ss.subspec "MediaSelect" do |sss|
      sss.source_files = 'GGBaseFramework/BaseFramework/Tools/MediaSelect/*.{h,m}'
    end
    ss.subspec "Other" do |sss|
      sss.source_files = 'GGBaseFramework/BaseFramework/Tools/*.{h,m}'
    end
  end

  s.subspec 'ViewController' do |ss|
    ss.dependency 'GGBaseFramework/Tools'
    ss.dependency 'Masonry'
    ss.source_files = 'GGBaseFramework/BaseFramework/ViewController/*.{h,m}'
    ss.resources = ['GGBaseFramework/BaseFramework/ViewController/**/*.png']
  end
  
  
end
