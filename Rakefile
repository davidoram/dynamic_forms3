require 'rubygems'
require 'erb'
require 'fileutils'
require 'rake/testtask'
require 'json'

desc "Run the server, in developer mode that will reload pages when you change the source"
task :dev do
  exec "shotgun -I lib"
end

desc "Build the documentation page to build/README.html"
task :doc do
  remove_file "build/README.html", true
  exec "asciidoc -d book -b xhtml11 -a toc -o build/README.html README.txt"
end

Rake::TestTask.new do |t|
  t.libs << "lib"
  t.test_files = FileList['lib/df3/*_test.rb']
  #t.verbose = true
end