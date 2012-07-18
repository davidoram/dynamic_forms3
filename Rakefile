require 'rubygems'
require 'erb'
require 'fileutils'
require 'rake/testtask'
require 'json'
require 'riak'

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





# Run 'rake RIAK_HOME=/my/path/to/riak', if you install riak somewhere else
riak_home = ENV['RIAK_HOME'] || "#{ENV['HOME']}/riak-1.1.4"
# Run 'rake RIAK_URL=http://hostname:port', if you run riak on another host or ports
riak_url = ENV['RIAK_URL'] || "http://localhost:8098"

namespace :riak do

  # See http://wiki.basho.com/Open-Files-Limit.html if you get open file limit errors
  
  task :check_riak_home do
    fail "Missing RIAK_HOME envar" if riak_home == ''
    fail "Missing RIAK_HOME/bin directory (#{riak_home}/bin)" unless File.directory?("#{riak_home}/bin")
  end
  
  desc "Ping Riak"
  task :ping => :check_riak_home do
    sh "#{riak_home}/bin/riak ping"
  end

  desc "Reload js libraries"
  task :reload_js => :check_riak_home do
    sh "#{riak_home}/bin/riak-admin js_reload"
  end

  desc "stop riak"
  task :stop => :check_riak_home do
    sh "#{riak_home}/bin/riak stop"
  end

  desc "start riak"
  task :start  => :check_riak_home do
    sh "#{riak_home}/bin/riak start"
    sleep(2)
  end

  desc "delete all the data stored in riak"
  task :drop => [:check_riak_home] do
    FileUtils.rm_rf("#{riak_home}/data")
  end

  desc "Stop riak, clobber the data, start and run migrations "
  task :clean => [:stop, :drop, :start, :migrate]
  
  desc "Load migrations into riak"
  task :migrate => [:check_riak_home] do
    Dir.glob('migrations/*.sh') do |sh_file|
      # Execute each migration shell script passing in the URL 
      sh "#{sh_file} #{riak_url}"
    end
  end
  
  desc "Run a mapreduce job"
  task :mapreduce => [:check_riak_home, :reload_js] do
    map = "function(value, keyData, arg){ 
           		var data = Riak.mapValuesJson(value)[0]; 
           		if(data.searchkeys) 
             			return [data.searchkeys]; 
           		else 
             			return []; 
          }"
    reduce = "function(valueList, arg){ 
                return _.unique(_.flatten(valueList));
              }"
    client = Riak::Client.new
    result = Riak::MapReduce.new(client).index('schemas', 'df_type_bin', 'schema').map(map).reduce(reduce, :keep => true).run
    puts '---------------------'
    puts result
  end
  

end