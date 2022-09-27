# Flight Subprocess

Flight Subprocess is a collection of utilities designed to run CLI tools in a
subprocess.  It supports running the subprocess on localhost or on a remote
machine via passwordless SSH.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'flight-subprocess'
```

And then execute:

```sh
$ bundle install
```

Or install it yourself as:

```sh
$ gem install flight-subprocess
```

## Usage

### Run a subprocess as the same user on localhost

```ruby
require 'flight-subprocess'
require 'logger'

logger = Logger.new(@stdout)

process = Flight::Subprocess::Local.new(
  # A logger object, to log with.
  logger: logger,

  # A hash of additional environment variables to set.  The hash is mandatory,
  # but can be empty.
  env: {},

  # The timeout in seconds for the command to complete.
  timeout: 60
)

# Run the command `ls -l` with no stdin.
result = process.run("ls -l", nil)
```

### Run a subprocess as a different user on localhost

```ruby
require 'flight-subprocess'
require 'logger'

logger = Logger.new(@stdout)

process = Flight::Subprocess::Local.new(
  logger: logger,
  env: {},
  timeout: 60,

  # The username of the user to run the process as.
  username: "bob",

  # Load the supplementary groups for the user, defaults to `false`.
  supplementary_groups: true
)

# Run the command `ls -l` with no stdin.
result = process.run("ls -l", nil)
```

### Run a subprocess in a particular directory on localhost

```ruby
require 'flight-subprocess'
require 'logger'

logger = Logger.new(@stdout)

process = Flight::Subprocess::Local.new(
  logger: logger,
  env: {},
  timeout: 60,

  # The directory in which to run the command.  If not given, it will be the
  ' home directory of the user that the command is ran as, see `username`.
  dir: "/opt"
)

# Run the command `ls -l` with no stdin.
result = process.run("ls -l", nil)
```

### Run a ruby block as another user on localhost

```ruby
require 'flight-subprocess'
require 'logger'

logger = Logger.new(@stdout)

process = Flight::Subprocess::Local.new(
  logger: logger,
  env: {},
  timeout: 60,

  # The username of the user to run the process as.
  username: "bob",

  # Load the supplementary groups for the user, defaults to `false`.
  supplementary_groups: true
)

# Don't run a command, but run a block instead.  A block and command can be
combined, in which case the block is ran prior to the command executing.
result = process.run(nil, nil) do |stdout, stderr|
  stdout.write("The uid for bob is #{Process.uid}")
end
```

### Run a remote process via passwordless SSH

The API for running remote processes is very similar to running local
processes.  Some additional parameters to the `new` method are required.

`flight-subprocess` requires that passwordless SSH access is already
configured.  It offers no help in configuring that or creating the SSH keys.

`flight-subprocess` requires that it is given the paths to an existing SSH key
pair supporting passwordless access.  `flight-subprocess` will add the public
key to the user's `.ssh/authorized_keys` file on localhost before starting the
SSH session.  There is an assumption that the home directory on localhost is
shared with the home directory on the target host.

For an example of how the SSH key pair might be created see [the post
installation
script](https://github.com/openflighthpc/openflight-omnibus-builder/blob/master/builders/flight-desktop-restapi/package-scripts/flight-desktop-restapi/stubs/postinst-configure)
for the `flight-desktop-restapi` package.

```ruby
require 'flight-subprocess'
require 'logger'

logger = Logger.new(@stdout)

process = Flight::Subprocess::Remote.new(
  logger: logger,
  env: {},
  timeout: 60

  # The host on which to run the command.
  host: "comp01",

  # An array of private SSH keys to use for passwordless SSH.
  keys: ["/path/to/private/ssh/key"],

  # The path to the public SSH key.
  public_key_path: "/path/to/public/ssh/key",

  # The timeout for establishing the SSH connection.
  connection_timeout: 10,
)

# Run the command `ls -l` with no stdin.
result = process.run("ls -l", nil)
```

### Access the result of the command

The result of the command or block can be accessed via the returned `Result`
object.

```ruby
result.stdout      # Returns the standard output of the process.
result.stderr      # Returns the standard error of the process.
result.exitstatus  # Returns the exit status of the process.
result.success?    # Returns a boolean of whether the command exited 0.
result.pid         # Returns the PID of the forked process if known.
```

### Missing functionality for remote processes

1. Remote processes do not yet support running a ruby block.
2. Remote processes do not yet support changing directory.  They always
   execute in the directory that SSH starts the shell in.
3. The PID of a remote process is not known.


## Development

After checking out the repo, run `bin/setup` to install dependencies. You can
also run `bin/console` for an interactive prompt that will allow you to
experiment.

TODO: Add instructions about releasing new versions here.

# Contributing

Fork the project. Make your feature addition or bug fix. Send a pull
request. Bonus points for topic branches.

Read [CONTRIBUTING.md](CONTRIBUTING.md) for more details.

Bug reports are also welcome on GitHub at
https://github.com/openflighthpc/flight-subprocess.

# Copyright and License

Eclipse Public License 2.0, see [LICENSE.txt](LICENSE.txt) for details.

Copyright (C) 2022-present Alces Flight Ltd.

This program and the accompanying materials are made available under
the terms of the Eclipse Public License 2.0 which is available at
[https://www.eclipse.org/legal/epl-2.0](https://www.eclipse.org/legal/epl-2.0),
or alternative license terms made available by Alces Flight Ltd -
please direct inquiries about licensing to
[licensing@alces-flight.com](mailto:licensing@alces-flight.com).

Flight Subprocess is distributed in the hope that it will be useful, but
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED
INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR CONDITIONS OF TITLE,
NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. See the
[Eclipse Public License 2.0](https://opensource.org/licenses/EPL-2.0) for more
details.
