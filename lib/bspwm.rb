module BSPWM
  class << self
    def flatten(opt_hash)
      opt_hash.collect { |k, v| "#{k}=#{v}" }.join(' ')
    end

    def command(*args)
      puts `bspc #{args}`
    end

    def rule_single(selector, opt_hash)
      command('rule -a', selector.to_s, flatten(opt_hash))
    end

    def config_single(opt, val)
      command('config', opt, val)
    end

    def rule(selectors, opt_hash)
      selectors.each { |s| rule_single(s, opt_hash) }
    end

    def rules(rule_hash)
      rule_hash.each { |selectors, opts| rule(selectors, opts) }
    end

    def monitor(workspaces)
      command('monitor -d', workspaces.join(' '))
    end

    def run(commands)
      commands.each { |command| Process.detach spawn(command) }
    end

    def config(opt, val = nil)
      if opt.class == Hash && val.nil?
        opt.each { |o, v| config_single(o, v) }
      elsif opt.class == Symbol && val
        config_single(opt, val)
      else
        raise ArgumentError, 'Supply either two args or a Hash'
      end
    end

    def configure(&block)
      instance_eval(&block)
    end
  end
end
