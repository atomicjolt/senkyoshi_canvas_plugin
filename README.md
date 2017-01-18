# Senkyoshi Canvas Plugin

This plugin enables the use of the Senkyoshi converter inside of Canvas. It adds a blackboard cartridge option to the import content dropdown for a course.

## Installation

Add a file inside the `Gemfile.d` folder

```ruby
# Gemfile.d/senkyoshi.rb
gem "canvas_cc", git: "https://github.com/atomicjolt/canvas_cc.git"
```

#### Rubygems
Add to Gemfile.d/senkyoshi.rb
```ruby
gem "senkyoshi_canvas_plugin"
```

#### Manual
```sh
sysadmin@appserver:~$ cd /path/to/canvas/gems/plugins
sysadmin@appserver:/path/to/canvas/gems/plugins$ git clone https://github.com/atomicjolt/senkyoshi_canvas_plugin.git
```
---
Now you need to add a couple lines of code to a coffeescript file.
Near the bottom, just above the `registerExternalTool` method add:
```coffeescript
  # app/coffeescripts/bundles/modules/content_migration_setup.coffee

  ConverterViewControl.register
    key: 'senkyoshi_importer'
    view: new CanvasExportView
      chooseMigrationFile: new ChooseMigrationFileView
        model: ConverterViewControl.getModel()
        fileSizeLimit: ENV.UPLOAD_LIMIT

      selectContent: new SelectContentCheckboxView
        model: ConverterViewControl.getModel()

      dateShift: new DateShiftView
        model: ConverterViewControl.getModel()
        collection: daySubCollection
        daySubstitution: daySubCollectionView
        oldStartDate: ENV.OLD_START_DATE
        oldEndDate: ENV.OLD_END_DATE
```

Now `bundle install` and `bundle exec rake canvas:compile_assets` and `rails server`.

After it is up, login with the site admin account and head over to the `/plugins` route (Navigated to by clicking `Admin -> Site Admin -> Plugins`).
Once there, scroll down to `Senkyoshi Conversion Importer` and click into it. Enable the plugin and add your Scorm information if needed.

You should be all set now. Enjoy!

