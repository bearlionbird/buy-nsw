module Sellers::SellerApplication::Contract
  class Base < Reform::Form
    include Concerns::Contracts::Composition
    include Concerns::Contracts::MultiStepForm
    include Concerns::Contracts::Status
    include Forms::ValidationHelper

    model :application

    # This Populator is used by multiple forms to handle loading, saving and
    # deletion of child objects.
    #
    NestedChildPopulator = ->(fragment:, collection:, index:, params:, context:, model_klass:, **) {
      id = fragment['id'] || fragment[:id]

      if id.present?
        item = collection.find { |item|
          item.id.to_s == id.to_s
        }

        record = model_klass.find_by(seller_id: context.seller_id, id: fragment['id'])
      end

      values = fragment.slice(*params).reject {|k,v| v.blank? }

      if values.empty?
        if item
          collection.delete(item)
        end

        # Invoke this manually because Reform doesn't seem to delete the record,
        # instead attemtping to zero out the foreign key (which violates the
        # database constraint)
        #
        if record
          record.destroy
        end

        return context.skip!
      end

      item ? item : collection.append(model_klass.new(:seller_id => context.seller_id))
    }

    def seller_id
      seller.id
    end

    def seller
      self.model[:seller]
    end

    def application
      self.model[:application]
    end

    def upload_for(key)
      self.model[:seller].public_send(key)
    end
  end
end
