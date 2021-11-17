# OpenProject Team Planner module
#
# Copyright (C) 2021 OpenProject GmbH
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

module OpenProject::TeamPlanner
  class Engine < ::Rails::Engine
    engine_name :openproject_team_planner

    include OpenProject::Plugins::ActsAsOpEngine

    register 'openproject-team_planner',
             author_url: 'https://www.openproject.org',
             bundled: true,
             settings: {},
             name: 'OpenProject Team Planner' do

      project_module :team_planner_view, dependencies: :work_package_tracking, order: 60 do
        permission :view_team_planner, 'team_planner/team_planner': %i[index], dependencies: :view_work_packages
      end

      menu :project_menu,
           :team_planner_view,
           { controller: '/team_planner/team_planner', action: :index },
           caption: :'team_planner.label_team_planner',
           after: :backlogs,
           icon: 'icon2 icon-calendar'
    end

  end
end
