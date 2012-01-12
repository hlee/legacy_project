$:.push(File.expand_path(File.dirname(__FILE__)))
require 'common'
#require 'switch'
#require 'analyzer'
module ConfigFiles
   class ConfigFile

      def initialize(magic_nbr, block_file=true)
         @magic_nbr=magic_nbr
      end
   end
   class HWFile
      def HWFile.save(id,filename)
         bfp=BlockFile::BlockFileParser.new()
         bfp.magic_nbr=BlockFile::BlockFileParser::CFG_MAGIC
         bfp.version=3
         analyzer=Analyzer.find(id)
         switches=analyzer.switches
         port_count =0

         anl_block={
            :name =>analyzer.name,
            :rtpt_count =>0,# We need to set this after building all the blocks.
            :mx_count =>switches.length,
            :location => analyzer.location,
            :unique_id => analyzer.id,
            :region => '',
            :_block_type => 1
         }
         switch_inc=0
         port_inc=0
         sw_list=Switch.find(:all,:conditions => ["analyzer_id=?", analyzer.id],
            :order =>:address)
         sw_list.each { |switch|
            switch_inc+=1
            port_count+=switch.switch_ports.length
            switch_block={
               :hw_mux_id =>switch.address,
               :name =>switch.switch_name,
               :port_count =>(switch.is_master? ? 0 : switch.switch_ports.length),
               :unique_id => switch_inc,
               :parent_pos_mux =>switch.address - 1,
               :parent_mux_id =>switch.address - 1,
               :baud_rate => analyzer.baud_rate,
               :protocol_nbr => 0,
               :switch_port => 1,
               :switch_type => 2,
               :location => switch.location || '',
               :_block_type => 2,
               :region => ''
            }
            bfp.block_list.push(switch_block)
            if (!switch.is_master?)
               switch.switch_ports.each { |sp|
                  port_inc += 1
                  sp_block = {
                     :name => sp.name,
                     :unique_id => port_inc,
                     :location => '',
                     :port_nbr=>sp.port_nbr,
                     :_block_type => 3,
                     :region => ''
                  }
                  bfp.block_list.push(sp_block)
               }
            end

         }
         anl_block[:rtpt_count] = port_inc
         bfp.block_list.unshift(anl_block)
         bfp.save(filename)

         return true
      end
   end

end
