class Buyers::ApplicationsController < Buyers::BaseController
  before_action :authenticate_user!, except: :manager_approve
  layout '../buyers/applications/_layout'

  def new
    run Buyers::BuyerApplication::Create do |result|
      return redirect_to buyers_application_path(result[:application_model].id)
    end

    flash.alert = I18n.t('buyers.applications.messages.already_submitted')
    redirect_to root_path
  end

  def show
    @operation = run Buyers::BuyerApplication::Update::Present
  end

  def update
    @operation = run Buyers::BuyerApplication::Update do |result|
      if result['result.submitted'] == true
        flash.notice = I18n.t('buyers.applications.messages.submitted')
        return redirect_to root_path
      else
        return redirect_to buyers_application_step_path(result[:application_model].id, result['result.next_step_slug'])
      end
    end

    render :show
  end

  def manager_approve
    @operation = run Buyers::BuyerApplication::ManagerApprove

    flash.notice = (operation['result.approved'] == true) ?
      I18n.t('buyers.applications.messages.manager_approve_success') :
        I18n.t('buyers.applications.messages.manager_approve_failure')

    return redirect_to root_path
  end

private
  def form
    @form
  end
  helper_method :form

  def operation
    @operation
  end
  helper_method :operation

  def application
    form.model[:application]
  end
  helper_method :application

  def _run_options(options)
    options.merge( "current_user" => current_user )
  end

end