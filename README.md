[![GitHub release](https://img.shields.io/github/release/gem-shards/candilano.svg)](https://github.com/gem-shards/candilano/releases)

# :candy: Candilano

A **multi-server deployment tool**, inspired by [Capistrano](https://capistranorb.com/), the deployment tool for Ruby.

This library is tailored to web applications and can be used to deploy your app to one or multiple servers in a consistent and  configureable way. It supports all web frameworks available for Crystal. The configuration is YAML based and is inspired by [Ansible](https://github.com/ansible/ansible).

Be aware this is still under development and can break things.

## Table of Contents
- [Installation](#installation)
- [Usage](#usage)
  - [Init](#init)
  - [Check](#check)
  - [Deploy](#deploy)
  - [Rollback](#rollback)
  - [Restart](#restart)
- [Configuration](#configuration)
- [Development](#development)
- [Contributing](#contributing)
- [Contributors](#contributors)

## Installation

1. Add the dependency to your `shard.yml`:
```yaml
dependencies:
  candilano:
    github: gem-shards/candilano
```
2. Run `shards install`

3. Add the following lines to your **targets** in shards.yml:

```yaml
targets:
  can:
    main: lib/candilano/src/candilano.cr
```

4. Run `shards build can` to build candilano

## Usage

### Init
Run init script in the projects root path:

```bash
./bin/can init
```

It will create a deploy directory with two yaml files for sandbox and production use. You can modify the files to your liking.

### Check
Run the `check` command to check if you can connect to your servers and see if it has all the permissions are set to start a deploy.

```bash
./bin/can check production
```

### Deploy
With the `deploy` command you will execute a deployment.

```bash
./bin/can deploy production
```

### Rollback
With the `rollback` command you will execute a deployment.

```bash
./bin/can rollback production
```

### Restart
With the `restart` command you can restart your running application.

```bash
./bin/can restart production
```

## Configuration
If you run the `init` command it will generate the following configuration:

```yaml
---
  app_name: 'your-app-name'
  repo_url: 'git@github:repo.git'
  branch: 'master'
  deploy_to: '/location/to/deploy'
  keep_releases: 5
  restart_command: 'service your-app-name restart'

  # Optionally, set a migrate command for database migrations
  # It will execute on the 'db' role only when it's present.
  # migrate_command: 'db migrate'

  ssh:
    user: user
    password: password
    port: 22
    key: '~/.ssh/id_rsa'
    forward_agent: true

  # linked_files:
  #   - 'config/settings.yml'

  # linked_directories:
  #  - 'log'
  #  - 'tmp'

  servers:
    - host: 127.0.0.1
      roles:
        - web
        - db
  # - host: 127.0.0.1
  #   roles:
  #     - web

  # hooks:
  #   before:
  #     - command: 'free'
  #       task_group: 'rollback:get_previous_version'
  #       target: 'remote'
  #       on_role: 'db'
  #   after:
  #     - command: 'free'
  #       task_group: 'rollback:get_previous_version'
  #       target: 'local'

```

## Development

This library is under development. It is already used in production by myself. I still want to implement the following features:

- Show more debug info if command fails
- Ansible like variables and checks
- Dry-run support
- Ability to write your own 'programs'

## Contributing

1. Fork it (<https://github.com/gem-shards/candilano/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Gem shards](https://github.com/gem-shards) - creator and maintainer
