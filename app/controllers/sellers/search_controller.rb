class Sellers::SearchController < Sellers::BaseController
  helper Sellers::ProfilesHelper

  def search
  end

private
  def search
    @search ||= Search::Seller.new(
      term: params[:q],
      selected_filters: params.except(:q),
      page: params.fetch(:page, 1),
      per_page: 25,
    )
  end
  helper_method :search
end
