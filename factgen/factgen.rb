require 'erb'
require 'csv'
CSV.foreach('keys.csv') do |row|
  fact_name = row[0]
  registry_hive = row[1]
  registry_key = row[2]
  registry_keyname = row[3]
  registry_keyvalue = row[5]
  template = ERB.new(File.read("registry.erb"))
  final_content = template.result(binding)
  File.open("#{fact_name}.rb","w") do |file|
    file.puts final_content
  end
end
