class Firmware < ActiveRecord::Base
  FIRMWARE_DIR="public/firmware"
  def initialize(fn)
    @filename=fn
    return self
  end
  def Firmware.sanitize_filename(value)
    just_filename=value.gsub(/^.*(\\|\/)/,'')
    @filename=just_filename.gsub(/[^\w\.\-]/,'_')
  end
  def filename()
    return @filename
  end
  def get_full_path()
    return "#{Firmware.base_path()}/#{@filename}"
  end
  def Firmware.base_path
    bp=File.expand_path(File.dirname(__FILE__))+"/../../#{FIRMWARE_DIR}"
    return bp
  end
  def self.save(firmware)
    filename=Firmware.sanitize_filename(firmware["file"].original_filename)
    if filename=~ /\.(run)|(gz)$/ 
      File.open("#{Firmware.base_path()}/#{filename}","w") { |f| f.write(firmware['file'].read) }
      return true
    else
      return false
    end
  end
  def Firmware.find(selector)
    entries=[]
    Dir.entries(base_path()).each { |fn|
      fp=File.join(base_path(),fn)
      if fn =~ /^\.\.$/
      elsif fn =~ /^\.$/
      elsif File.directory?(fp)
      elsif File.symlink?(fp)
      else
        fw_obj=Firmware.new(fn)
        entries.push(fw_obj)
      end
    }
    if selector==:all
      return entries
    else
      entries.each { |entry|
        if entry.filename == selector
          logger.debug("Found #{selector}")
          return [entry]
        end
      }
    end
    return []
  end
  def destroy
    self.delete
  end
  def delete
    logger.debug("Deleting again #{filename}")
    if File.exists? "#{Firmware.base_path()}/#{@filename}"
      File.delete "#{Firmware.base_path()}/#{@filename}"
    end
  end
end
