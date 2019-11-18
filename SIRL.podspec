Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.name         = "SIRL"
  s.version      = "1.1.16"
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
  s.platform     = :ios, "9.0"
  s.swift_version = '4.2'

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source       = { :git => "https://github.com/sirl-io/ios_sdk.git",
                     :tag => "#{s.version}" }
  # --- Subspecs --------------------------------------------------------------- #

  #s.default_subspec = 'Core'
  s.module_map = "Core/libs/include/module.modulemap"
  s.vendored_frameworks = "Core/SIRLCore.framework"
  s.preserve_paths = "Core/libs/include/module.modulemap"
  s.vendored_libraries = "Core/libs/*.a"
  s.source_files  = "Core/libs/include/*.{h}"
  s.libraries = "c++"
  s.requires_arc = true
  s.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2',
                      'SWIFT_INCLUDE_PATHS' => '$(PODS_ROOT)/SIRL/libs/include'}
end
