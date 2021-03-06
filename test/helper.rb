require 'rubygems'
require 'bundler'
Bundler.setup
Bundler.require(:default, :development)

if defined?(Debugger)
  ::Debugger.start
  ::Debugger.settings[:autoeval] = true if ::Debugger.respond_to?(:settings)
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'active_record_host_pool'
require 'logger'

RAILS_ENV = "test"

ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/test.log")
ActiveRecord::Base.configurations = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))

require 'active_support/test_case'

class ActiveSupport::TestCase
  private
  def arhp_create_databases
    ActiveRecord::Base.configurations.each do |name, conf|
      `echo "drop DATABASE IF EXISTS #{conf['database']}" | mysql --user=#{conf['username']}`
      `echo "create DATABASE #{conf['database']}" | mysql --user=#{conf['username']}`
      ActiveRecord::Base.establish_connection(name)
      ActiveRecord::Migration.verbose = false
      load(File.dirname(__FILE__) + "/schema.rb")
    end
  end

  def arhp_drop_databases
    ActiveRecord::Base.configurations.each do |name, conf|
      ActiveRecord::Base.connection.execute("DROP DATABASE #{conf['database']}")
    end
  end

  def arhp_create_models
    return if Object.const_defined?("Test1")
    eval <<-EOL
      class Test1 < ActiveRecord::Base
        set_table_name "tests"
        establish_connection("test_host_1_db_1")
      end

      class Test2 < ActiveRecord::Base
        set_table_name "tests"
        establish_connection("test_host_1_db_2")
      end

      class Test3 < ActiveRecord::Base
        set_table_name "tests"
        establish_connection("test_host_2_db_3")
      end

      class Test4 < ActiveRecord::Base
        set_table_name "tests"
        establish_connection("test_host_2_db_4")
      end
    EOL
  end

  def current_database(klass)
    klass.connection.select_value("select DATABASE()")
  end
end
