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

module Flight
  module Subprocess
    autoload 'Local', File.expand_path('subprocess/local', __dir__)
    autoload 'Remote', File.expand_path('subprocess/remote', __dir__)
  end
end

require_relative 'subprocess/version'
require_relative 'subprocess/result'
