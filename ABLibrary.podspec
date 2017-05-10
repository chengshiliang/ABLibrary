Pod::Spec.new do |s|
  s.name         = 'ABLibrary'
  s.version      = '0.0.1'
  s.summary      = 'ABLibrary is a high level request util based on ABAddressbook and CNContact.'
  s.homepage     = 'https://github.com/chengshiliang/ABLibrary'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'chengshiliang' => '285928582@qq.com' }
  s.source       = { :git => 'https://github.com/chengshiliang/ABLibrary.git', :tag => s.version.to_s }
  s.platform     = :ios, '8.0'
  s.source_files = 'ABLibrary/*.{h,m}'
  s.requires_arc = true
  s.frameworks   = 'Foundation', 'UIKit', 'Contacts', 'AddressBook' 
  #s.dependency   'FMDB', '~> 2.0'
 #s.library      = 'sqlite3'
end