class Sellers::SellerApplication::Products::Create < Trailblazer::Operation
  step :model!
  step :persist!

  def model!(options, params:, **)
    options[:application_model] = options['current_user'].seller_applications.find(params[:application_id])
    options[:seller_model] = options[:application_model].seller
    options[:product_model] = options[:seller_model].products.build
  end

  def persist!(options, **)
    options[:product_model].save!
  end
end