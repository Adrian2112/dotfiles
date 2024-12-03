# https://gist.github.com/justin808/1fe1dfbecc00a18e7f2a
#
# Using these pry gems
# gem install pry
# gem install pry-rails
# gem install pry-byebug
# gem install pry-stack_explorer
# gem install pry-doc
# gem install pry-state
# gem install pry-toys
# gem install pry-rescue
require 'pry-byebug'

### START debundle.rb ###

# MIT License
# Copyright (c) Conrad Irwin <conrad.irwin@gmail.com>
# Copyright (c) Jan Lelis <mail@janlelis.de>

module Debundle
  VERSION = '1.1.0'

  def self.debundle!
    return unless defined?(Bundler)
    return unless Gem.post_reset_hooks.reject! do |hook|
      hook.source_location.first =~ %r{/bundler/}
    end

    if defined? Bundler::EnvironmentPreserver
      ENV.replace(Bundler::EnvironmentPreserver.new(ENV.to_h, %w[GEM_PATH]).backup)
    end
    Gem.clear_paths

    load 'rubygems/core_ext/kernel_require.rb'
    load 'rubygems/core_ext/kernel_gem.rb'
  rescue StandardError
    warn 'DEBUNDLE.RB FAILED'
    raise
  end
end

### END debundle.rb ###

include Rails::ConsoleMethods if defined?(::Rails) and defined?(::Rails::ConsoleMethods) && Rails.env

Pry::Commands.block_command 'noconflict', 'Rename step to sstep and next to nnext' do
  Pry::Commands.rename_command('nnext', 'next')
end

Pry::Commands.block_command 'unnoconflict', 'Revert to normal next and break' do
  Pry::Commands.rename_command('next', 'nnext')
end

Pry.config.editor = 'vim'

## Benchmarking
# Inspired by <http://stackoverflow.com/questions/123494/whats-your-favourite-irb-trick/123834#123834>.

def do_time_reps(repetitions, *procs, warmup: true, log_level: :error, &block)
  require 'benchmark'
  if defined?(Rails)
    previous_level = Rails.logger.level
    Rails.logger.level = log_level
  end
  procs_with_labels = {}
  procs_with_labels[:block] = block if block_given?
  procs.each_with_index do |proc, i|
    procs_with_labels["proc #{i}"] = proc
  end
  labels = procs_with_labels.keys
  label_size = labels.map(&:size).max

  benchmark = lambda do
    procs_with_labels.map do |label, proc|
      # Benchmark.measure(label) { repetitions.times { proc.call } }.tap do |result|
      #  puts "#{label.rjust(label_size)}: #{(result.real / repetitions.to_f).round(4)}"
      # end
      results = repetitions.times.map { Benchmark.measure { proc.call } }
      mean = results.sum(&:real) / repetitions.to_f
      std_dev = Math.sqrt(results.sum { |r| (r.real - mean)**2 } / (repetitions - 1))

      puts "#{label.rjust(label_size)}: AVG #{mean.round(4)} STDDEV #{std_dev.round(4)}"
      OpenStruct.new(label: label, real: mean, std_dev: nil)
    end
  end

  if warmup
    puts 'Warming up --------------------------------------'
    benchmark.call
  end

  puts 'Calculating -------------------------------------'
  results = benchmark.call

  puts 'Comparison:'
  results = results.sort_by(&:real)

  results.each_with_index do |result, i|
    print "#{result.label}: AVG #{result.real.round(4)}"
    print " - #{(result.real / results[0].real).round(2)}x slower" if i != 0
    print "\n"
  end
  nil
ensure
  Rails.logger.level = previous_level if defined?(Rails)
end

def do_time(*procs, log_level: :error, &block)
  # Debundle.debundle!
  $: << '/Users/adriangonzalez/.rvm/gems/ruby-3.1.4/gems/benchmark-ips-2.12.0'
  $: << '/Users/adriangonzalez/.rvm/gems/ruby-3.1.4/gems/benchmark-ips-2.12.0/lib'
  require 'benchmark/ips'
  if defined?(Rails)
    previous_level = Rails.logger.level
    Rails.logger.level = log_level
  end
  Benchmark.ips do |b|
    b.report('block', &block) if block_given?

    procs.each_with_index do |proc, i|
      b.report("proc #{i}") { proc.call }
    end

    b.compare!
  end
  nil
ensure
  Rails.logger.level = previous_level if defined?(Rails)
end

Pry.config.color = true
Pry.config.prompt = Pry::NAV_PROMPT if defined? Pry::NAV_PROMPT

Pry.config.commands.alias_command 'h', 'hist -T 20', desc: 'Last 20 commands'
Pry.config.commands.alias_command 'hg', 'hist -T 20 -G', desc: 'Up to 20 commands matching expression'
Pry.config.commands.alias_command 'hG', 'hist -G', desc: 'Commands matching expression ever used'
Pry.config.commands.alias_command 'hr', 'hist -r', desc: 'hist -r <command number> to run a command'

Pry.commands.alias_command 'cc', 'continue'
Pry.commands.alias_command 'ss', 'step'
Pry.commands.alias_command 'nn', 'next'
Pry.commands.alias_command 'ff', 'finish'

begin
  require 'amazing_print'
  # Pry.config.print = proc { |output, value| output.puts value.ai }
  AmazingPrint.pry!
rescue LoadError => e
  puts 'no amazing_print :('
end

my_hook = Pry::Hooks.new.add_hook(:before_session, :add_dirs_to_load_path) do
  # adds the directories /spec and /test directories to the path if they exist and not already included
  dir = `pwd`.chomp
  dirs_added = []
  %w[spec test presenters lib].map { |d| "#{dir}/#{d}" }.each do |p|
    if File.exist?(p) && !$:.include?(p)
      $: << p
      dirs_added << p
    end
  end
  puts "Added #{dirs_added.join(', ')} to load path in ~/.pryrc." if dirs_added.present?
end

my_hook.exec_hook(:before_session)

require 'spec_helper' if defined?(Rails) && Rails.env.test?

puts 'Loaded ~/.pryrc'
puts
def more_help
  puts 'Helpful shortcuts:'
  puts 'hh  : hist -T 20       Last 20 commands'
  puts 'hg : hist -T 20 -G    Up to 20 commands matching expression'
  puts 'hG : hist -G          Commands matching expression ever used'
  puts 'hr : hist -r          hist -r <command number> to run a command'
  puts

  puts 'Samples variables'
  puts 'a_array  :  [1, 2, 3, 4, 5, 6]'
  puts 'a_hash   :  { hello: "world", free: "of charge" }'
  puts
  puts 'helper   : Access Rails helpers'
  puts 'app      : Access url_helpers'
  puts
  puts 'require "rails_helper"              : To include Factory Girl Syntax'
  puts 'include FactoryGirl::Syntax::Methods  : To include Factory Girl Syntax'
  puts
  puts 'or if you defined one...'
  puts 'require "pry_helper"'
  puts
  puts 'Sidekiq::Queue.new.clear              : To clear sidekiq'
  puts 'Sidekiq.redis { |r| puts r.flushall } : Another clear of sidekiq'
  puts
  puts 'Debugging Shortcuts'
  puts 'ss  :  step'
  puts 'nn  :  next'
  puts 'cc  :  continue'
  puts 'fin :  finish'
  puts 'uu  :  up'
  puts 'dd  :  down'
  puts 'ww  :  whereami'
  puts 'ff  :  frame'
  puts 'sss :  show-stack'
  puts '$   :  show whole method of context'
  puts
  puts "Run 'pry_debug' to display shorter debug shortcuts"
  ''
end
puts "Run 'more_help' to see tips"
