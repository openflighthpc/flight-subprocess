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
#===============================================================================

module Flight
  module Subprocess
    class SshKey
      def initialize(env:, key_path:, logger:, timeout:, username: nil)
        @env = env
        @key_path = key_path
        @logger = logger
        @timeout = timeout
        @username = username
      end

      def install
        @logger.info("Installing public key if needed")
        run_sub_process do
          ensure_authorized_keys_file_exists
          open_key_file do |file|
            if key_exists?(file)
              @logger.info("Key already exists")
            else
              write_key(file)
              @logger.info("Updated authorized_keys")
            end
          end
        end
      end

      def remove
        @logger.info("Removing public key if needed")
        run_sub_process do
          unless File.exist?(keys_file)
            @logger.info("authorized keys file not found")
          else
            open_key_file do |file|
              if key_exists?(file)
                remove_key(file)
                @logger.info("Updated authorized_keys")
              else
                @logger.info("Key not found")
              end
            end
          end
        end
      end

      private

      def key
        @_key ||=
          begin
            @logger.debug("Reading public key from #{@key_path.inspect}")
            File.read(@key_path)
          end
      end

      def keys_file
        @_keys_file ||=
          begin
            passwd = Etc.getpwuid
            File.expand_path(File.join(passwd.dir, ".ssh/authorized_keys")).tap do |path|
              @logger.debug("authorized_keys file expanded to #{path.inspect}")
            end
          end
      end

      def run_sub_process(&block)
        process = Local.new(
          env: @env,
          logger: @logger,
          supplementary_groups: true,
          timeout: @timeout,
          username: @username,
        )
        process.run(nil, nil, &block)
      end

      def ensure_authorized_keys_file_exists
        dir = File.dirname(keys_file)
        FileUtils.mkdir(dir, mode: 0700) unless Dir.exist?(dir)

        unless File.exist?(keys_file)
          FileUtils.touch(keys_file)
          FileUtils.chmod(0600, keys_file)
        end
      end

      def open_key_file(&block)
        File.open(keys_file, 'r+', &block)
      end

      def key_exists?(file)
        file.each_line do |line|
          return true if line.chomp == key.chomp
        end
        false
      ensure
        file.rewind
      end

      def write_key(file)
        begin
          file.seek(-1, :END)
          char = file.read
          file.write("\n") unless char[-1] == "\n"
        rescue Errno::EINVAL
          # Empty files cannot seek to the -1 position.  This is to be expected
          # and can be ignored.
        end

        file.puts(key)
      end

      def remove_key(file)
        new_lines = []
        file.each_line do |line|
          new_lines << line if line.chomp != key.chomp
        end
        file.rewind
        file.truncate(0)
        file.puts(new_lines)
      end
    end
  end
end
