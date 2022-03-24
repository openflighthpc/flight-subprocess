#==============================================================================
# Copyright (C) 2022-present Alces Flight Ltd.
#
# This file is part of Flight Subprocess.
#
# This program and the accompanying materials are made available under
# the terms of the Eclipse Public License 2.0 which is available at
# <https://www.eclipse.org/legal/epl-2.0>, or alternative license
# terms made available by Alces Flight Ltd - please direct inquiries
# about licensing to licensing@alces-flight.com.
#
# Flight Subprocess is distributed in the hope that it will be useful, but
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS OR
# IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR CONDITIONS
# OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A
# PARTICULAR PURPOSE. See the Eclipse Public License 2.0 for more
# details.
#
# You should have received a copy of the Eclipse Public License 2.0
# along with Flight Subprocess. If not, see:
#
#  https://opensource.org/licenses/EPL-2.0
#
# For more information on Flight Subprocess, please visit:
# https://github.com/openflighthpc/flight-subprocess
#==============================================================================
require_relative 'lib/flight/subprocess/version'

Gem::Specification.new do |spec|
  spec.name          = "flight-subprocess"
  spec.version       = Flight::Subprocess::VERSION
  spec.authors       = ["Alces Flight Ltd"]
  spec.email         = ["flight@openflighthpc.org"]

  spec.summary       = "Functions to run CLI tools in subprocesses"
  spec.license       = 'EPL-2.0'
  spec.homepage      = "https://github.com/openflighthpc/flight-subprocess"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/openflighthpc/flight-subprocess"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.7'

  # spec.add_runtime_dependency('addressable', '~> 2.5')
end
