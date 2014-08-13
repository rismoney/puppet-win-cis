path = File.expand_path(File.join(__FILE__, '..'))
$LOAD_PATH.unshift path unless $LOAD_PATH.member?(path)
load "cisfacts.rb"

