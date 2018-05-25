module Sellers::SellerApplication::Contract
  class Characteristics < Base
    property :number_of_employees, on: :seller
    property :corporate_structure, on: :seller

    property :start_up,                            on: :seller
    property :sme,                                 on: :seller
    property :not_for_profit,                      on: :seller

    property :rural_remote,                        on: :seller
    property :regional,                            on: :seller
    property :travel,                              on: :seller

    property :australian_owned,                    on: :seller
    property :disability,                          on: :seller
    property :female_owned,                        on: :seller
    property :indigenous,                          on: :seller

    property :no_experience,                       on: :seller
    property :local_government_experience,         on: :seller
    property :state_government_experience,         on: :seller
    property :federal_government_experience,       on: :seller
    property :international_government_experience, on: :seller

    validation :default do
      required(:seller).schema do
        # TODO: These don't currently return a nice human-friendly
        # error message currently
        required(:number_of_employees).
          value(included_in?: Seller.number_of_employees.values)
        required(:corporate_structure).
          value(included_in?: Seller.corporate_structure.values)
      end
    end
  end
end