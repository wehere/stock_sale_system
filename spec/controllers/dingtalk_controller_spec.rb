require 'rails_helper'

RSpec.describe DingtalkController, :type => :controller do

  describe "GET upload_score" do
    it "returns http success" do
      get :upload_score
      expect(response).to be_success
    end
  end

end
