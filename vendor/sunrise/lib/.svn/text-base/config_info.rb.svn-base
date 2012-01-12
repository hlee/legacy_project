require 'singleton'
require 'rubygems'
require 'fileutils'
require 'yaml'
require 'rubygems'
require 'active_record'

# Config information is stored in the ConfigInfo Singleton class
class ConfigInfo
   include Singleton
   attr_reader :instrument_list,:instrument_mode,:params,:db_config,:rails_db
   DEFAULT_FILENAME=File.expand_path(File.dirname(__FILE__))+'/../config/server.yaml'
   INGRESS=1
   PERFORMANCE=2
   STANDBY=3
   MAINT=0

# Initialize the Config info object.  Also load config data.
# 1. Load server.yaml
# 2. See if we have 
   def initialize()
      #      if (File.file? DEFAULT_FILENAME)
      #         load_file(DEFAULT_FILENAME)
      #      end
   end
   def init_data()
      #      ActiveRecord::Base.establish_connection(:adapter=>@db_config['adapter'],
      #   :host=>@db_config['host'],:username=>@db_config['username'],
      #   :password => @db_config['password'],
      #   :database=>@db_config['database'])
      @instrument_list=[]
      @instrument_mode={}
      Analyzer.find(:all).each { |anl|
         @instrument_list.push(anl.ip)
         @instrument_mode[anl.ip]=STANDBY
      }
   end
   def load_file(fname)
      if File.exists? fname
         content=open(fname,'r').read()
         load_content(content)
      else
      end
   end
   def load_content(content)
      @db_config={}
      params=YAML.load(content)
      #See if rails_home is defined
      if params.key?('rails_home')
         $:.push(params['rails_home'])
      end
#      if params.key?('adapter') #Looks to see if we have an db adapter defined
#         @db_config['adapter']=params['adapter']
#         @db_config['host']=params['host']
#         @db_config['username']=params['username']
#         @db_config['database']=params['database']
#
#      elsif params.key?('rails_db')#If not let's try taking rails configuration
#         rails_env=ENV['RAILS_ENV']||'development'
#         rails_db_file=YAML.load(params['rails_db'])
#         @rails_db=YAML.load_file(rails_db_file)
#         @db_config=@rails_db[rails_env]
#      end
#      if !@db_config.key?('adapter')
#         raise 'Database adapter is not defined'
#      end
#      if !@db_config.key?('host')
#         raise 'Database host is not defined'
#      end
#      if !@db_config.key?('username')
#         raise 'Database username is not defined'
#      end
#
#      if !@db_config.key?('database')
#         raise 'Database database  is not defined'
#      end
   end

   # instrument_modes=>  INGRESS,PERFORMANCE,STANDBY,QUIT
   def cfg_mode(instr, mode)
      @instrument_mode[instr]=mode
   end
   def get_mode(instr)
      return @instrument_mode[instr]
   end

end

ConfigInfo.instance()
