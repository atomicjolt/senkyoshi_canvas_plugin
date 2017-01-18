module SenkyoshiCanvasPlugin
  NAME = "Senkyoshi Conversion Importer".freeze
  DISPLAY_NAME = "Blackboard Cartridge".freeze
  DESCRIPTION =
    "This enables importing Blackboard Cartridges into Canvas.".freeze
  class Engine < ::Rails::Engine
    isolate_namespace SenkyoshiCanvasPlugin

    config.autoload_paths << File.expand_path(File.join(__FILE__, "../.."))

    config.to_prepare do
      Canvas::Plugin.register(
        :senkyoshi_importer,
        :export_system,
        name: -> { I18n.t(:senkyoshi_name, NAME) },
        display_name: -> { I18n.t :senkyoshi_display, DISPLAY_NAME },
        author: "Atomic Jolt",
        author_website: "http://www.atomicjolt.com/",
        description: -> { t(:description, DESCRIPTION) },
        version: SenkyoshiCanvasPlugin::VERSION,
        settings_partial: "senkyoshi_canvas_plugin/plugin_settings",
        select_text: -> do
          I18n.t(:senkyoshi_importer_description, DISPLAY_NAME)
        end,
        settings: {
          worker: "SenkyoshiWorker",
          migration_partial: "canvas_config",
          requires_file_upload: true,
          provides: {
            bb_learn: CC::Importer::Canvas::Converter,
          },
          valid_contexts: %w{Account Course},
        },
      )
    end
  end
end
