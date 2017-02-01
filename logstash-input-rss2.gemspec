Gem::Specification.new do |s|
  s.name = 'logstash-input-rss2'
  s.version         = '0.0.1'
  s.licenses        = ['Apache-2.0']
  s.summary         = "Extended RSS/Atom input plugin for Logstash"
  s.description     = "This gem is a Logstash plugin required to be installed on top of the Logstash core pipeline using $LS_HOME/bin/logstash-plugin install gemname. This gem is not a stand-alone program"
  s.authors         = ['mkoertgen', 'ThomasMentzel']
  s.email           = 'marcel.koertgen@gmail.com'
  s.homepage        = 'https://github.com/awesome-inc/logstash-input-rss2'
  s.require_paths = ['lib']

  # Files
  s.files = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE','NOTICE.TXT']
   # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { 'logstash_plugin' => 'true', 'logstash_group' => 'input' }

  # Gem dependencies
  s.add_runtime_dependency 'stud', '>= 0.0.22', '< 0.1.0'
  s.add_runtime_dependency 'feedjira', '2.0.0'
  s.add_runtime_dependency 'rippersnapper', '>= 0.0.8'

  s.add_development_dependency 'logstash-devutils'
  s.add_development_dependency "logstash-core-plugin-api", "~> 2.0"
  s.add_development_dependency 'logstash-codec-plain'
end
