class SendOrderMessageJob < ApplicationJob
  queue_as :default

  def perform(id)
    SendOrderMessage.send_email(id)
  end
end
