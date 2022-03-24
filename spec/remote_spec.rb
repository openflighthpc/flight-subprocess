require_relative "./spec_helper"
require_relative "./log_helper"
require_relative './shared_examples'

require "sshkey"

require "flight/subprocess"
require "flight/subprocess/ssh_key"

PUBLIC_KEY_PATH = File.expand_path("../tmp/key.pub", __dir__).freeze
PRIVATE_KEY_PATH = File.expand_path("../tmp/key", __dir__).freeze

RSpec.configure do |config|
  config.before(:suite) do
    k = SSHKey.generate(comment: "flight-subprocess temporary test key")
    File.write(PUBLIC_KEY_PATH, k.ssh_public_key)
    File.write(PRIVATE_KEY_PATH, k.private_key)
  end

  config.after(:suite) do
    Flight::Subprocess::SshKey.new(
      env: {},
      key_path: PUBLIC_KEY_PATH,
      logger: FakeLogger.new(log: false),
      timeout: 1,
    ).remove
  end
end

RSpec.describe "Flight::Subprocess::Remote" do
  include_context "subprocess shared context"
  let(:subprocess) {
    Flight::Subprocess::Remote.new(
      connection_timeout: 1,
      env: env,
      host: "localhost",
      keys: [ PRIVATE_KEY_PATH ],
      logger: logger,
      public_key_path: PUBLIC_KEY_PATH,
      timeout: timeout,
    )
  }

  # include_examples "when the cli tool echoes back stdin"
  include_examples "when the cli tool exceeds the timeout" do
    # Not sure why the process receives SIGILL.  It ought to be sent TERM/KILL
    # to be inline with Local.
    let(:expected_exitstatus) { 128 + Signal.list["ILL"] }
  end
  include_examples "when the cli tool has no output and is succesful" 
  include_examples "when the cli tool has stdout, stderr and is succesful"
  include_examples "when the cli tool has stdout, stderr and is unsuccesful"
  include_examples "when the output is large"
end
