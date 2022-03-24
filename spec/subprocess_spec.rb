require_relative './spec_helper'

RSpec.describe "Subprocess" do
  it "has a version" do
    expect(Flight::Subprocess.constants).to include :VERSION
  end
end
