require 'spec_helper'

describe Counselor do
  describe "url" do
    it "uses the name of the user" do
      user = User.new(first_name: 'joe', last_name: 'doe')
      counselor = Counselor.new user: user
      expect(counselor.url) == 'joe-doe'
    end
  end

  describe "high res image" do
    it "stores the file" do
      counselor = create(:counselor, high_res_image: File.open("#{Rails.root}/spec/fixtures/hires.png", 'rb'))
      expect(File.file?(counselor.high_res_image.path)).to be_true
    end

    after(:all) do
     FileUtils.rm_rf("#{Rails.root}/public/system")
    end
  end

  describe 'client_price_for' do
    let(:counselor) { create :counselor, price_per_session_hour: 75 }
    let(:client) {create :user}

    it 'returns a new client price instance initialized with the counselors default session price in cents' do
      expect(counselor.client_price_for(client).amount).to eq(75)
      expect(counselor.client_price_for(client).client).to eq(client)
    end

    it 'returns the existing client price for matching client' do
      ClientPrice.create! amount_in_cents: 3000, client: client, counselor: counselor
      expect(counselor.client_price_for(client).amount).to eq(30)
    end
  end
end
