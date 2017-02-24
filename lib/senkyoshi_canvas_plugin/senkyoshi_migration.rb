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
