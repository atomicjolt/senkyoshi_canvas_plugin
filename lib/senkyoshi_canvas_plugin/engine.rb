# Copyright (C) 2017 Atomic Jolt

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

module SenkyoshiCanvasPlugin
  NAME = "Senkyoshi Conversion Importer".freeze
  DISPLAY_NAME = "Blackboard Cartridge".freeze
  DESCRIPTION =
    "This enables importing Blackboard Cartridges into Canvas.".freeze
  class Engine < ::Rails::Engine
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
      require "senkyoshi_canvas_plugin/senkyoshi_migration"
    end
  end
end
