begin
  require 'haml'
rescue LoadError
  puts <<-INSTRUCTIONS
This plugin require HAML, please install it:
  sudo gem install haml

Then add it to your environment.rb file:
  # config/environment.rb:
  config.gem 'haml'
INSTRUCTIONS
end

puts "Copying files..."
path=File.expand_path(File.dirname(__FILE__))
["app", "public"].each do |dir|
  FileUtils.cp_r("#{path}/#{dir}", RAILS_ROOT)
end

puts <<-INSTRUCTIONS
Files copied - Installation complete!

If you want to generate custom 404 pages then edit your routes file and remove the default routes :
  # config/routes.rb
  map.connect ':controller/:action/:id'"
  map.connect ':controller/:action/:id.:format'

Then add this line AT THE BOTTOM of your routes file:
  # config/routes.rb
  map.not_found '*path', :controller => 'application', :action => 'render_not_found'
INSTRUCTIONS
