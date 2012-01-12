require File.dirname(__FILE__) + '/../test_helper'

class FirmwareTest < Test::Unit::TestCase

   def setup
      Dir.chdir(File.join(File.dirname(__FILE__),'..','..'))
      @firmware_path=Firmware.base_path()
      if File.symlink?(File.join(@firmware_path,'z_link'))
         File.unlink File.join(@firmware_path,'z_link')
      end
      if File.exists?(File.join(@firmware_path,'x'))
         File.delete File.join(@firmware_path,'x')
      end
      if File.exists?(File.join(@firmware_path,'y'))
         File.delete File.join(@firmware_path,'y')
      end
      if File.exists?(File.join(@firmware_path,'z'))
         File.delete File.join(@firmware_path,'z')
      end
   end
   def teardown
      if File.symlink?(File.join(@firmware_path,'z_link'))
         File.unlink File.join(@firmware_path,'z_link')
      end
      if File.exists?(File.join(@firmware_path,'x'))
         File.delete File.join(@firmware_path,'x')
      end
      if File.exists?(File.join(@firmware_path,'y'))
         File.delete File.join(@firmware_path,'y')
      end
      if File.exists?(File.join(@firmware_path,'z'))
         File.delete File.join(@firmware_path,'z')
      end
   end
   def test_firmware
      len=Firmware.find(:all).entries.length 
      file_a=File.join(@firmware_path,'x')
      system("touch #{file_a}")
      file_a=File.join(@firmware_path,'y')
      system("touch #{file_a}")
      file_a=File.join(@firmware_path,'z')
      system("touch #{file_a}")
      assert_equal Firmware.find(:all).entries.length , (len +3)# remove '.' and '..' and .svn
      File.symlink('z',file_a+"_link")
      assert_equal Firmware.find(:all).entries.length , (len +3)# remove '.' and '..' and .svn
      fw=Firmware.find('y')
      fw[0].destroy
      assert !File.exists?(File.join(@firmware_path,'y'))
      assert_equal Firmware.find(:all).entries.length , (len + 2)# remove '.' and '..' and .svn
      fw=Firmware.find('x')
      fw[0].destroy
      assert !File.exists?(File.join(@firmware_path,'x'))
      assert_equal Firmware.find(:all).entries.length , (len + 1)# remove '.' and '..' and .svn
      fw=Firmware.find('z')
      fw[0].destroy
      assert !File.exists?(File.join(@firmware_path,'z'))
      assert_equal Firmware.find(:all).entries.length , (len + 0)# remove '.' and '..' and .svn

   end
end
