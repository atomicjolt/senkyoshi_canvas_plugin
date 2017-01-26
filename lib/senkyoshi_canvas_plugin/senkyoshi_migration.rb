require_dependency "app/controllers/content_migrations_controller"

ENGINE_ROOT = SenkyoshiCanvasPlugin::Engine.root

class ContentMigrationsController
  alias index_without_senkyoshi index
  def index
    index_without_senkyoshi
    if !performed?
      render file: "#{ENGINE_ROOT}/app/views/content_migrations/index.erb"
    end
  end
end
