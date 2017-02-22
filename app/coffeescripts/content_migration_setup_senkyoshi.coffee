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

# Parts of this file have been copied from Instructures file located at
# https://github.com/instructure/canvas-lms/blob/4d944663f8ee9e17eb20fdf280333f9a6c04e749/app/coffeescripts/bundles/modules/content_migration_setup.coffee

define [
  'jquery'
  'i18n!content_migrations'
  'compiled/collections/DaySubstitutionCollection'
  'compiled/views/CollectionView'
  'compiled/views/content_migrations/ConverterViewControl'
  'compiled/views/content_migrations/CanvasExportView'
  'compiled/views/content_migrations/subviews/ChooseMigrationFileView'
  'compiled/views/content_migrations/subviews/SelectContentCheckboxView'
  'compiled/views/content_migrations/subviews/DateShiftView'
  'compiled/views/content_migrations/subviews/DaySubstitutionView'
  'vendor/jquery.ba-tinypubsub'
  'jst/content_migrations/subviews/DaySubstitutionCollection'
  'compiled/bundles/modules/content_migration_setup'
], (
  $,
  I18n,
  DaySubstitutionCollection,
  CollectionView,
  ConverterViewControl,
  CanvasExportView,
  ChooseMigrationFileView,
  SelectContentCheckboxView,
  DateShiftView,
  DaySubView,
  pubsub,
  daySubCollectionTemplate
) ->

  emptyMessage = I18n.t('no_day_substitutions', "No Day Substitutions Added")
  daySubCollection = new DaySubstitutionCollection
  daySubCollectionView = new CollectionView
    collection: daySubCollection
    emptyMessage: -> emptyMessage
    itemView: DaySubView
    template: daySubCollectionTemplate

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
