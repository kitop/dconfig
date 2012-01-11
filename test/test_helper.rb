require 'dconfig'
require 'test/unit'

# make sure we can run redis
#
if !system("which redis-server")
  puts '', "** can't find `redis-server` in your path"
  abort ''
end

dir = File.dirname(File.expand_path(__FILE__))

at_exit do
  next if $!

  if defined?(MiniTest)
    exit_code = MiniTest::Unit.new.run(ARGV)
  else
    exit_code = Test::Unit::AutoRunner.run
  end

  processes = `ps -A -o pid,command | grep [r]edis-test`.split("\n")
  pids = processes.map { |process| process.split(" ")[0] }
  puts "Killing test redis server..."
  `rm -f #{dir}/dump.rdb #{dir}/dump-cluster.rdb`
  pids.each { |pid| Process.kill("KILL", pid.to_i) }
  exit exit_code
end

##
# test/spec/mini 3
# http://gist.github.com/25455
# chris@ozmm.org
# file:lib/test/spec/mini.rb
#
def context(*args, &block)
  return super unless (name = args.first) && block
  require 'test/unit'
  klass = Class.new(defined?(ActiveSupport::TestCase) ? ActiveSupport::TestCase : Test::Unit::TestCase) do
    def self.test(name, &block) 
      define_method("test_#{name.gsub(/\W/,'_')}", &block) if block
    end
    def self.xtest(*args) end
    def self.setup(&block) define_method(:setup, &block) end
    def self.teardown(&block) define_method(:teardown, &block) end
  end
  (class << klass; self end).send(:define_method, :name) { name.gsub(/\W/,'_') }
  klass.class_eval &block
end

puts "Starting redis for testing at localhost:9736..."
`redis-server #{dir}/redis-test.conf`
Dconfig.redis = 'localhost:9736'
