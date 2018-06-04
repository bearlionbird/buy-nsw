module Search
  class BuyerApplication < Base

    def available_filters
      {
        assigned_to: assigned_to_keys,
        state: state_keys,
      }
    end

  private
    def base_relation
      ::BuyerApplication.all
    end

    def state_keys
      ::BuyerApplication.aasm.states.map(&:name)
    end

    def assigned_to_keys
      ::User.admin.map {|user|
        [ user.email, user.id ]
      }
    end

    def apply_filters(scope)
      scope.yield_self(&method(:state_filter)).
            yield_self(&method(:assigned_to_filter))
    end

    def state_filter(relation)
      state_keys.each do |state|
        if filter_selected?(:state, state)
          relation = relation.in_state(state)
        end
      end
      relation
    end

    def assigned_to_filter(relation)
      if filter_selected?(:assigned_to)
        relation.assigned_to( filter_value(:assigned_to) )
      else
        relation
      end
    end
  end
end