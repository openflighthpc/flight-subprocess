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

require 'etc'
require 'timeout'
require 'net/ssh'

require_relative './ssh_key'

module Flight
  module Subprocess
    class Remote
      def initialize(
        connection_timeout:,
        env:,
        host:,
        keys:,
        logger:,
        public_key_path:,
        timeout:,
        username: nil,
        **ignored
      )
        @connection_timeout = connection_timeout
        @env = env
        @host = host
        @keys = keys
        @logger = logger
        @public_key_path = public_key_path
        @timeout = timeout
        @username = username.nil? ? Etc.getpwuid.name : username
      end

      def run(cmd, stdin, &block)
        @stdout = ""
        @stderr = ""
        @exit_code = nil
        @exit_signal = nil
        @timedout = false

        with_timout do
          install_public_ssh_key
          run_command(cmd, stdin, &block)
        end
        pid = "<Unknown: Remote process>"

        Result.new(@stdout, @stderr, determine_exit_code, pid)
      end

      private

      def with_timout(&block)
        # XXX Send a TERM/KILL signal to the remote process too.
        Timeout.timeout(@timeout, &block)
      rescue Timeout::Error
        @timedout = true
        @logger.info("Aborting remote process; timeout exceeded.")
      end

      def install_public_ssh_key
        SshKey.new(
          env: @env,
          key_path: @public_key_path,
          logger: @logger,
          timeout: @timeout,
          username: @username
        ).install
      end

      def run_command(*cmd, stdin, &block)
        @logger.info("Starting SSH session #{cmd_debug(cmd)} keys=#{@keys.inspect}")
        Net::SSH.start(@host, @username, keys: @keys, timeout: @connection_timeout) do |ssh|
          ssh.open_channel do |channel|
            @logger.debug("SSH session started. Executing cmd #{cmd_debug(cmd)}")
            channel.exec(cmd_string(cmd)) do |ch, success|
              unless success
                @logger.error("Failed to execute command")
              end

              channel.on_data do |ch, data|
                @logger.debug("Received stdout data: #{data.inspect}")
                @stdout << data
              end

              channel.on_extended_data do |ch, type, data|
                @logger.debug("Received stderr data: #{data.inspect}")
                @stderr << data
              end

              channel.on_request("exit-status") do |ch, data|
                @exit_code = data.read_long
                @logger.debug("Received exit-status: #{@exit_code}")
              end

              channel.on_request("exit-signal") do |ch, data|
                @exit_signal = data.read_long
                @logger.debug("Received exit-signal: #{@exit_signal}")
              end

              if success && !stdin.nil?
                ch.send_data(stdin)
              end
            end
          end

          ssh.loop
        end
      end

      def determine_exit_code
        if @exit_signal
          @logger.debug "Inferring exit code from signal"
          @exit_signal + 128
        elsif @exit_code
          @exit_code
        else
          @logger.debug "No exit code provided"
          128
        end
      end

      def cmd_string(cmd)
        env_string = @env.map { |k, v| "#{k}=#{v}" }.join(" ")
        [env_string, *cmd].join(" ")
      end

      def cmd_debug(cmd)
        "(#{@username}@#{@host}) #{cmd.join(" ")}"
      end
    end
  end
end
