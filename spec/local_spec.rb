require_relative './spec_helper'
require_relative './log_helper'
require_relative './shared_examples'

require 'flight/subprocess'

RSpec.describe "Flight::Subprocess::Local" do
  include_context "subprocess shared context"
  let(:subprocess) {
    Flight::Subprocess::Local.new(logger: logger, env: env, timeout: timeout)
  }

  include_examples "when the cli tool echoes back stdin"
  include_examples "when the cli tool exceeds the timeout"
  include_examples "when the cli tool has no output and is succesful" 
  include_examples "when the cli tool has stdout, stderr and is succesful"
  include_examples "when the cli tool has stdout, stderr and is unsuccesful"
  include_examples "when the output is large"
end
