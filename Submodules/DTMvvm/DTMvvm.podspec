Pod::Spec.new do |s|
  s.name             = 'DTMvvm'
  s.version          = '0.0.1'
  s.summary          = 'DTMvvm'
  s.description      = 'DTMvvm'

  s.homepage         = 'https://gapo.vn'
  s.license          = { :type => 'MIT'}
  s.author           = { 'Thang Le' => 'lethang255@gmail.com' }
  s.source           = { :git => 'https://github.com/ios4vn/Mute.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/ahussein'

  s.ios.deployment_target = '10.0'

  s.source_files = 'DTMvvm/Classes/*.swift', 'DTMvvm/Classes/*/*.swift', 'DTMvvm/Classes/*/*/*.swift', 'DTMvvm/Classes/*/*/*/*.swift', 'DTMvvm/Classes/*/*/*/*/*.swift'
  s.resource_bundles = {
      'DTMvvm' => ["DTMvvm/*/*.{png,xib,xcassets}", "DTMvvm/*/*/*.{png,xib,xcassets}"]
  }

  s.dependency 'RxSwift'
  s.dependency 'RxCocoa'
  s.dependency 'Action'
  s.dependency 'Alamofire'
  s.dependency 'AlamofireImage'
  s.dependency 'ObjectMapper'
  s.dependency 'PureLayout'
  s.dependency 'Moya'
  
  s.swift_version = '5.0'
end
