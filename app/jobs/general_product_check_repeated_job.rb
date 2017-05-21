class GeneralProductCheckRepeatedJob < ApplicationJob
  queue_as :default

  def perform(supplier_id)
    GeneralProduct.check_repeated supplier_id
  end
end
