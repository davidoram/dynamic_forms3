require 'rubygems'
require 'erb'
require 'fileutils'
require 'rake/testtask'
require 'json'

desc "Build the documentation page"
task :doc do
  exec "asciidoc -d book -b xhtml11 -a toc -o build/README.html README.txt "
end


Rake::TestTask.new do |t|
  t.libs << "lib"
  t.test_files = FileList['lib/df3/*_test.rb']
  #t.verbose = true
end