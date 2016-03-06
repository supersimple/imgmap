require 'rails_helper'

RSpec.describe Job, type: :model do
  describe '.generate' do
    it "should create a new Job" do
      expect(Job.generate(["http://google.com", "http://supersimple.org"])).to be_kind_of(Job)
    end
  end
end