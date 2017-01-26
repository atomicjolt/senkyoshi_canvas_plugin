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

  noDaySubstitutions = "No Day Substitutions Added"
  daySubCollection = new DaySubstitutionCollection
  daySubCollectionView = new CollectionView
    collection: daySubCollection
    emptyMessage: -> I18n.t('no_day_substitutions', noDaySubstitutions)
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
