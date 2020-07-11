# :candy: Candilano

A multi-server deployment tool, inspired by Capistrano, the awesome deployment tool for Ruby. Although it a bit similar, it's not exactly the same.

This library is tailored to web applications and can be used to deploy your applications to one or multiple servers in a consistent way and easily configureable way. It supports all web frameworks available for Crystal. The configuration is YAML based and is inspired by Ansible.

## Table of Contents
- [Installation](#installation)
- [Usage](#usage)
  - [Init](#init)
  - [Check](#check)
  - [Deploy](#deploy)
  - [Rollback](#rollback)
- [Development](#development)
- [Contributing](#contributing)
- [Contributors](#contributors)

## Installation

1. Add the dependency to your `shard.yml`:
```yaml
dependencies:
  candilona:
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
