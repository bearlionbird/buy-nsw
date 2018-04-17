class Ops::BuyerApplicationsController < Ops::BaseController

  layout ->{
    action_name == 'index' ? 'ops' : '../ops/buyer_applications/_layout'
  }

  def show
  end

  def assign
    run Ops::BuyerApplication::Assign do |result|
      flash.notice = I18n.t('ops.buyer_applications.messages.update_assign_success')
      return redirect_to ops_buyer_application_path(application)
    end

    render :show
  end

  def decide
    run Ops::BuyerApplication::Decide do |result|
      decision = result['contract.default'].decision
      flash.notice = I18n.t("ops.buyer_applications.messages.decision_success.#{decision}")
      return redirect_to ops_buyer_application_path(application)
    end

    render :show
  end

private
  def applications
    @applications ||= BuyerApplication.includes(:seller)
  end
  helper_method :applications

  def search
    @search ||= BuyerApplicationSearch.new(
      selected_filters: params,
    )
  end
  helper_method :search

  def application
    @application ||= BuyerApplication.find(params[:id])
  end
  helper_method :application

  def forms
    @forms ||= {
      assign: ops[:assign]['contract.default'],
      decide: ops[:decide]['contract.default'],
    }
  end
  helper_method :forms

  def ops
    @ops ||= {
      assign: (run Ops::BuyerApplication::Assign::Present),
      decide: (run Ops::BuyerApplication::Decide::Present),
    }
  end
end