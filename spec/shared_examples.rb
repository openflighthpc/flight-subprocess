RSpec.shared_context "subprocess shared context" do
  let(:env) { {} }
  let(:logger) { FakeLogger.new(log: false) }
  let(:stdin) { "" }
  let(:timeout) { 1 }
  subject { subprocess.run(cmd, stdin) }
end

RSpec.shared_examples "subprocess has the expected results" do
  it "has the expected exitstatus" do
    expect(subject.exitstatus).to eq expected_exitstatus
  end

  it "has the expected stdout" do
    expect(subject.stdout).to eq expected_stdout
  end

  it "has the expected stderr" do
    expect(subject.stderr).to eq expected_stderr
  end
end

RSpec.shared_examples "when the cli tool has no output and is succesful" do
  context "when the cli tool has no output and is succesful" do
    let(:cmd) { File.expand_path('stubs/no-output-exit-0.sh', __dir__) }

    let(:expected_exitstatus) { 0 }
    let(:expected_stdout) { "" }
    let(:expected_stderr) { "" }

    include_examples "subprocess has the expected results"
  end
end

RSpec.shared_examples "when the cli tool has stdout, stderr and is succesful" do
  context "when the cli tool has stdout, stderr and is succesful" do
    let(:cmd) { File.expand_path('stubs/stdout-stderr-exit-0.sh', __dir__) }

    let(:expected_exitstatus) { 0 }
    let(:expected_stdout) { [
      "This is the expected standard out.",
      "It is over multiple lines.",
      "",
    ].join("\n") }
    let(:expected_stderr) { [
      "This is the expected standard error.",
      "Standard error is interleaved with standard out.",
      "It is also over multiple lines.",
      "",
    ].join("\n") }

    include_examples "subprocess has the expected results"
  end
end

RSpec.shared_examples "when the cli tool has stdout, stderr and is unsuccesful" do
  context "when the cli tool has stdout, stderr and is unsuccesful" do
    let(:cmd) { File.expand_path('stubs/stdout-stderr-exit-1.sh', __dir__) }

    let(:expected_exitstatus) { 1 }
    let(:expected_stdout) { [
      "Making progress...",
      "Everything looking good...",
      "",
    ].join("\n") }
    let(:expected_stderr) { [
      "Oh no! Something has gone wrong!",
      "",
    ].join("\n") }

    include_examples "subprocess has the expected results"
  end
end

RSpec.shared_examples "when the cli tool echoes back stdin" do
  context "when the cli tool echoes back stdin" do
    let(:cmd) { File.expand_path('stubs/echo-back-stdin.sh', __dir__) }

    let(:expected_exitstatus) { 0 }
    let(:expected_stdout) { stdin }
    let(:expected_stderr) { "" }

    context "when stdin is empty" do
      let(:stdin) { "" }
      include_examples "subprocess has the expected results"
    end

    context "when stdin is nil" do
      let(:stdin) { nil }
      let(:expected_stdout) { "" }
      include_examples "subprocess has the expected results"
    end

    context "when stdin is a string" do
      let(:stdin) { "ping!\n" }
      include_examples "subprocess has the expected results"
    end
  end
end

RSpec.shared_examples "when the output is large" do
  context "when the output is large" do
    let(:cmd) { File.expand_path('stubs/large-stdout.sh', __dir__) }
    let(:pipe_max_size) { File.read("/proc/sys/fs/pipe-max-size").to_i }
    let(:expected_exitstatus) { 0 }
    let(:expected_stdout) { "\0" * pipe_max_size * 2 }
    let(:expected_stderr) { [
      "2+0 records in",
      "2+0 records out",
      "#{pipe_max_size * 2} bytes (2.1 MB) copied",
      "",
    ].join("\n") }

    include_examples "subprocess has the expected results"

    it "has so much stdout" do
      expect(subject.stdout.length).to be >= (pipe_max_size * 2)
    end
  end
end

RSpec.shared_examples "when the cli tool exceeds the timeout" do
  context "when the cli tool exceeds the timeout" do
    let(:cmd) { [ File.expand_path('stubs/exceeds-timeout.sh', __dir__), timeout.to_s ] }

    let(:expected_exitstatus) { super() rescue 128 + Signal.list["TERM"] }
    let(:expected_stdout) { [
      "Sent prior to timeout of #{timeout}",
      "",
    ].join("\n") }
    let(:expected_stderr) { "" }

    include_examples "subprocess has the expected results"
  end
end
