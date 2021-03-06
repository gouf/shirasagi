class Article::Agents::Parts::PageController < ApplicationController
  include Cms::PartFilter::View
  helper Cms::ListHelper

  public
    def index
      @items = Article::Page.site(@cur_site).public(@cur_date).
        where(@cur_part.condition_hash(cur_path: @cur_path)).
        order_by(@cur_part.sort_hash).
        limit(@cur_part.limit)
    end
end
