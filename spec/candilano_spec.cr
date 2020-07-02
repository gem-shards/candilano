require "./spec_helper"

describe Candilano do
  # TODO: Write tests

  it "works" do
    setup = Candilano::Setup.new("uptime", "sandbox")
    p setup.execute
    true.should eq(true)
  end
end
