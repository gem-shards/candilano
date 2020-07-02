require "./helpers/*"

module Candilano
  class Cli < Clim
    main do
      desc "\033[92mCandilano - Deploy your code\033[0m\n"
      usage "can [command] [environment]"
      run do |opts, _args|
        puts opts.help_string # => help string.
      end
      sub "deploy" do
        desc "run a deploy"
        usage "can deploy [environment]"
        run do |_opts, args|
          setup = Candilano::Setup.new("deploy", args.all_args.first)
          puts setup.execute
        end
      end
      sub "check" do
        desc "run checks"
        usage "can check [environment]"
        run do |_opts, args|
          setup = Candilano::Setup.new("check", args.all_args.first)
          puts setup.execute
        end
      end
      sub "rollback" do
        desc "rollback to previous release"
        usage "can rollback [environment]"
        run do |_opts, args|
          setup = Candilano::Setup.new("rollback", args.all_args.first)
          puts setup.execute
        end
      end
      sub "init" do
        desc "initialize and setup Cadilano"
        usage "can init"
        run do |_opts, _args|
          setup = Candilano::Setup.new("init", "no_env")
          puts setup.execute
        end
      end
    end
  end
end
