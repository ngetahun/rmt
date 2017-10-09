# rubocop:disable Rails/Exit

class RMT::CLI::Base < Thor

  class << self

    # custom output of the help command
    # (removes the alphabetical sorting and adds some custom behavior)
    def help(shell, subcommand = false)
      list = printable_commands(true, subcommand)

      list.reject! { |l| l[0].split.include?('help') }

      shell.say 'Commands:'

      shell.print_table(list, indent: 2, truncate: true)
      shell.say
      class_options_help(shell)

      shell.say "Run '#{basename} COMMAND help [SUBCOMMAND]' for more information on a command."
    end

    def dispatch(command, given_args, given_opts, config)
      super(command, given_args, given_opts, config)
    rescue RMT::CLI::Error => e
      warn e.to_s
      if config[:shell]&.base&.options&.[]('debug')
        warn e.cause ? e.cause.inspect : e.inspect
        warn e.cause ? e.cause.backtrace : e.backtrace
      end
      exit 1
    rescue Mysql2::Error => e
      warn "Cannot connect to database server. Please make sure it is running and configured in '/etc/rmt.conf'."
      warn 'Database error:'
      warn e.to_s
      exit 2
    rescue ActiveRecord::NoDatabaseError => e
      warn "The RMT database has not yet been initialized. Please run 'systemctl start rmt-migration' to setup the database."
      warn 'Database error:'
      warn e.to_s
      exit 2
    end

  end

end
