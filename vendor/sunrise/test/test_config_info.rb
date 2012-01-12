#!/usr/bin/ruby

base_dir = File.expand_path(File.dirname(__FILE__))
$:.push(base_dir)
require 'lib/config_info'
require 'test/unit'
ENV['RAILS_ENV']='test'

class ConfigInfoTest < Test::Unit::TestCase
   def test_load_content
      ci=ConfigInfo.instance()
      base_dir = File.expand_path(File.dirname(__FILE__))
      ci.load_content("
      rails_home: /usr/local/apache2/htdocs/realworx
      rails_db: #{base_dir}/../test/database1.yml")
      assert ci.db_config.key?("username")
      assert_equal "root",ci.db_config["username"]
      assert ci.db_config.key?("adapter")
      assert_equal "mysql",ci.db_config["adapter"]
      assert ci.db_config.key?("host")
      assert !ci.db_config["host"].nil?
      assert ci.db_config.key?("password")
      assert !ci.db_config["password"].nil?
      assert ci.db_config.key?("database")
      assert_equal "realworx_test",ci.db_config["database"]
   end
end
