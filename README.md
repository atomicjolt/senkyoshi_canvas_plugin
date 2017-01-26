# Senkyoshi Canvas Plugin

This plugin enables the use of the Senkyoshi converter inside of Canvas. It adds a blackboard cartridge option to the import content dropdown for a course.

## Installation

Add a file inside the `Gemfile.d` folder

```ruby
# Gemfile.d/senkyoshi.rb
gem "canvas_cc", git: "https://github.com/atomicjolt/canvas_cc.git"
```

```sh
sysadmin@appserver:~$ cd /path/to/canvas/gems/plugins
sysadmin@appserver:/path/to/canvas/gems/plugins$ git clone https://github.com/atomicjolt/senkyoshi_canvas_plugin.git
```

Now `bundle install` and `bundle exec rake canvas:compile_assets` and `rails server`.

After it is up, login with the site admin account and head over to the `/plugins` route (Navigated to by clicking `Admin -> Site Admin -> Plugins`).
Once there, scroll down to `Senkyoshi Conversion Importer` and click into it. Enable the plugin and add your Scorm information if needed.

You should be all set now. Enjoy!

