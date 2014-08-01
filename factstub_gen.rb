require 'erb'
require 'csv'
CSV.foreach('keys.csv') do |row|
  fact_name = row[0]


content = <<END
path = File.expand_path(File.join(__FILE__, '..'))
$LOAD_PATH.unshift path unless $LOAD_PATH.member?(path)
load "cisfacts.rb"
END

  File.open("#{fact_name}.rb","w") do |file|
    file.puts content
  end
end
