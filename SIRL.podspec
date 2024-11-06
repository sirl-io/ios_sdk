Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.name         = "SIRL"
  s.version      = "2.0.9"
  s.summary      = "SIRL SDKs"

  s.description  = "This is the set of SDKs for the SIRL system."

  s.homepage     = "https://www.sirl.io"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See http://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #

  s.license      = { :type => "Copyright SIRL Inc. 2019" }

  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.author             = { "Wei Cai" => "wei.cai@sirl.io" }

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.platform     = :ios, "13.0"
  s.swift_version = '5.1'

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source       = { :git => "https://github.com/sirl-io/ios_sdk.git",
                     :tag => "#{s.version}" }
  # --- Subspecs --------------------------------------------------------------- #

  s.default_subspec = 'Core'
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

  s.subspec 'Core' do |core|
    core.vendored_frameworks = "Core/SIRLCore.xcframework"
    core.preserve_paths = "Core/libs/include/module.modulemap"
    core.vendored_libraries = "Core/libs/*.a"
    core.source_files  = "Core/libs/include/*.{h}"
    core.libraries = "c++"
    core.requires_arc = true
    core.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2',
                      'SWIFT_INCLUDE_PATHS' => '$(PODS_ROOT)/SIRL/Core/libs/include'}
  end

  s.subspec 'Map' do |map|	
    map.vendored_frameworks = "Map/SIRLMap.framework"
    map.resource_bundles = {'SIRL_MapSDK' => ['Resource/*.xcassets']}	
    map.requires_arc = true
    map.dependency 'SIRL/Core'	
    #map.dependency 'Mapbox-iOS-SDK', '5.7.0'
    #map.dependency 'Floaty', '4.1.0'
  end	

  s.subspec 'Retail' do |ret|	
    ret.vendored_frameworks = "Retail/SIRLRetail.framework"
    ret.dependency 'SIRL/Map'	
  end

  s.subspec 'User' do |usr|	
    usr.vendored_frameworks = "User/SIRLUser.framework"
    usr.dependency 'SIRL/Core'	
  end

  s.subspec 'Asset' do |asset|	
    asset.vendored_frameworks = "Asset/SIRLAsset.framework"
    asset.dependency 'SIRL/Core'	
  end

end
