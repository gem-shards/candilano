# :candy: Candilano

A multi-server deployment tool, inspired by Capistrano, the awesome deployment tool for Ruby. Although it a bit similar, it's not exactly the same.

## :electric_plug: Installation

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

## :wrench: Usage

### Init
Run init script in the projects root path:

```bash
./bin/can init
```

It will create a deploy directory with two yaml files for sandbox and production use. You can modify the files to your liking.

### Check
Run the `check` command to check if you can connect to your servers and see if it has all the permissions to start a deploy.

```bash
./bin/can check production
```

### Deploy
With the `deploy` command you will execute a deployment.

```bash
./bin/can deploy production
```

## :hammer: Development

This library is under development. It is already used in production for myself. I still want to implement the following features:

- Rollback is priority
- Show more debug info if command fails
- Ansible like variables and checks
- Dry-run support
- Programmable config files
- Ability to write your own 'programs'

## :muscle: Contributing

1. Fork it (<https://github.com/gem-shards/candilano/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Gem shards](https://github.com/gem-shards) - creator and maintainer
