class Facility::MapsController < ApplicationController
  include Facility::PageFilter

  model Facility::Map

  append_view_path "app/views/cms/pages"

  private
    def fix_params
      { cur_user: @cur_user, cur_site: @cur_site, cur_node: @cur_node }
    end
end
