if defined?(Haml)
  puts "Copying files..."
  path=File.expand_path(File.dirname(__FILE__))
  ["app", "public"].each do |dir|
    FileUtils.cp_r("#{path}/#{dir}", RAILS_ROOT)
  end
  puts "Files copied - Installation complete!"

  puts "If you want to generate custom 404 pages then edit routes.rb and remove the default routes :"
  puts "map.connect ':controller/:action/:id'"
  puts "map.connect ':controller/:action/:id.:format'"
  puts
  puts "Then add this line AT THE BOTTOM of your routes.rb :"
  puts "map.not_found '*path', :controller => 'application', :action => 'render_not_found'"
else
  puts "This plugin require HAML , please install it : sudo gem install haml"
  puts "Then retry this install again..."
end