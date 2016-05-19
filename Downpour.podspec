Pod::Spec.new do |s|
  s.name             = "Downpour"
  s.version          = "0.1.0"
  s.summary          = "Get TV & Movie info from downloaded filenames"

  s.description      = <<-DESC
Downpour was built for [Fetch](http://getfetchapp.com) — a Put.io client — to parse TV & Movie information from downloaded files. It can gather the following from a raw file name:

- TV or movie title
- Year of release
- TV season number
- TV episode number
                       DESC

  s.homepage         = "https://github.com/steve228uk/Downpour"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Stephen Radford" => "steve228uk@gmail.com" }
  s.source           = { :git => "https://github.com/steve228uk/Downpour.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/steve228uk'

  s.osx.deployment_target = '10.10'
  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'

  s.source_files = 'Pod/**/*'

end
