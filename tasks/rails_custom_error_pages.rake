namespace :rcep do
  desc 'Update rails_custom_error_pages plugin'
  task :safe_update do
    system "script/plugin install -f git://github.com/smeevil/rails_custom_error_pages.git"
  end

  desc 'Update rails_custom_error_pages plugin and auto-commit it to git.'
  task :update do
    system "script/plugin install -f git://github.com/smeevil/rails_custom_error_pages.git && git add . && git commit -m 'Updated rails_custom_error_pages to latest version'"
  end
end