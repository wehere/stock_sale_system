class OrderItemClassifyJob < ApplicationJob
  self.queue_adapter = :sidekiq

  queue_as :default


  def perform(company_id, specified_date)
    OrderItem.classify company_id, specified_date
  end
end
