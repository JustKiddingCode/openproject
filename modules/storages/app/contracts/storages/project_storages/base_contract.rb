#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2012-2023 the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See COPYRIGHT and LICENSE files for more details.
#++

# A "contract" is an OpenProject pattern used to validate parameters
# before actually creating, updating, or deleting a model.
# Used by: projects_storages_controller.rb and in the API
module Storages::ProjectStorages
  class BaseContract < ::ModelContract
    # "Concern" just injects a permission checking routine.
    # Not sure where this concern is reused.
    include ::Storages::ProjectStorages::Concerns::ManageStoragesGuarded
    # Include validation library
    include ActiveModel::Validations

    attribute :project
    validates_presence_of :project
    attribute :storage
    validates_presence_of :storage

    attribute :project_folder_id

    attribute :project_folder_mode do
      unless @model.project_folder_inactive? || @model.project_folder_manual?
        errors.add :project_folder_mode, :invalid
      end
    end

    def assignable_storages
      Storages::Storage.visible(user).where.not(id: @model.project.projects_storages.pluck(:storage_id))
    end
  end
end
