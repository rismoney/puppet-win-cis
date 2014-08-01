require 'erb'
require 'csv'
path_to_csv = 'facts/keys.csv'
name = []
csv_contents = CSV.read(path_to_csv)
csv_contents.shift
csv_contents.each do |row|
fact_name = row[0]
content = <<END
path = File.expand_path(File.join(__FILE__, '..'))
$LOAD_PATH.unshift path unless $LOAD_PATH.member?(path)
load "cisfacts.rb"
END

  File.open("facts/#{fact_name}.rb","w") do |file|
    file.puts content
  end
end
