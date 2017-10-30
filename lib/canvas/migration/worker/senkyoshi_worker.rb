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

require "senkyoshi"

ARGUMENT_ERROR =
  "converter_class required for content migration with no file".freeze

module Canvas
  module Migration
    module Worker
      class SenkyoshiWorker < Base
        def perform
          migration ||= ContentMigration.where(id: migration_id).first
          migration.job_progress.start unless migration.skip_job_progress

          begin
            migration.update_conversion_progress(1)

            settings = _setup_settings(migration)

            # Create the imscc file using Senkyoshi
            imscc_path = settings[:file_path].ext(".imscc")
            Senkyoshi.parse_and_process_single(settings[:file_path], imscc_path)

            migration.update_conversion_progress(50)

            if File.exists?(imscc_path)
              _process_imscc(migration, settings, imscc_path)
            else
              text = I18n.t(:no_imscc_file, "Imscc file creation failed.")
              raise Canvas::Migration::Error, text
            end
          rescue Canvas::Migration::Error => e
            migration.add_error(e.message, exception: e)
            migration.workflow_state = :failed
            migration.job_progress.fail unless migration.skip_job_progress
            migration.save
          rescue => e
            migration.fail_with_error!(e) if migration
          end
        end

        def self.enqueue(content_migration)
          Delayed::Job.enqueue(
            new(content_migration.id),
            priority: Delayed::LOW_PRIORITY,
            max_attempts: 1,
            strand: content_migration.strand,
          )
        end

        def _setup_settings(migration)
          settings = migration.migration_settings.clone
          settings[:content_migration_id] = migration_id
          settings[:user_id] = migration.user_id
          settings[:content_migration] = migration

          if migration.attachment
            settings[:attachment_id] = migration.attachment.id
            settings[:file_path] = migration.attachment.full_filename
          elsif settings[:file_url]
            attachment = Canvas::Migration::Worker.
              download_attachment(migration, settings[:file_url])
            settings[:attachment_id] = attachment.id
            settings[:file_path] = attachment.full_filename
          elsif !settings[:no_archive_file]
            no_migration_file = "File required for content migration."
            text = I18n.t(:no_migration_file, no_migration_file)
            raise Canvas::Migration::Error, text
          end
          settings
        end

        def _process_imscc(migration, settings, imscc_path)
          # Get the attachment for the ContentMigration
          # And change its file to the imscc file temporarily
          attachment = migration.attachment
          attachment.write_attribute(:filename, File.basename(imscc_path))
          attachment.save

          converter_class = settings[:converter_class]
          unless converter_class
            if settings[:no_archive_file]
              raise ArgumentError, ARGUMENT_ERROR
            end
            settings[:archive] = Canvas::Migration::Archive.new(settings)
            converter_class = settings[:archive].get_converter
          end

          converter = converter_class.new(settings)
          course = converter.export
          export_folder_path = course[:export_folder_path]
          overview_file_path = course[:overview_file_path]

          _process_converted_data(
            migration,
            overview_file_path,
            export_folder_path,
          )

          migration.migration_settings[:worker_class] = converter_class.name
          migration.migration_settings[:migration_ids_to_import] =
            { copy: { everything: true } }.merge(
              migration.migration_settings[:migration_ids_to_import] || {},
            )
          if path = converter.course[:files_import_root_path]
            migration.migration_settings[:files_import_root_path] = path
          end

          migration.workflow_state = :exported
          saved = migration.save
          migration.update_conversion_progress(100)

          if migration.import_immediately? && !migration.for_course_copy?
            _import_scorm(migration, settings)
            saved = _import_content(migration, settings, attachment, converter)
          end
          saved
        end

        def _process_converted_data(migration,
                                    overview_file_path,
                                    export_folder_path)
          if overview_file_path
            file = File.new(overview_file_path)
            Canvas::Migration::Worker::upload_overview_file(file, migration)
            migration.update_conversion_progress(90)
          end

          if export_folder_path
            Canvas::Migration::Worker::upload_exported_data(
              export_folder_path,
              migration,
            )
            Canvas::Migration::Worker::clear_exported_data(
              export_folder_path,
            )
          end
        end

        def _import_scorm(migration, settings)
          plugin = PluginSetting.find_by(name: "senkyoshi_importer")
          if !plugin.disabled
            Senkyoshi.configure do |config|
              config.scorm_url = plugin.settings[:scorm_url]
              config.scorm_launch_url = plugin.settings[:scorm_launch_url]
              config.scorm_shared_id = plugin.settings[:scorm_shared_id]
              config.scorm_shared_auth = plugin.settings[:scorm_shared_auth]
              config.scorm_oauth_consumer_key =
                plugin.settings[:scorm_oauth_consumer_key]
            end

            meta = {
              name: migration.context.name,
            }
            Zip::File.open(settings[:file_path], "rb") do |bb_zip|
              senkyoshi_course = Senkyoshi::CanvasCourse.new(
                meta,
                migration.context,
                bb_zip,
              )
              senkyoshi_course.process_scorm(local: true)
            end
            migration.update_import_progress(90)
          end
        end

        def _import_content(migration, settings, attachment, converter)
          migration.import_content

          # Now that the import is done, change the attachment back
          # to the blackboard zip for record keeping
          attachment.write_attribute(
            :filename,
            File.basename(settings[:file_path]),
          )
          attachment.save
          migration.update_import_progress(100)
          saved = migration.save
          if converter.respond_to?(:post_process)
            converter.post_process
          end
          saved
        end
      end
    end
  end
end
