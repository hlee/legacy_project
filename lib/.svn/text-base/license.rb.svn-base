class License
  # Read only access to these attributes
  attr_reader :mac_address, :license_expiration_date, :ingress, :performance
  attr_reader :last_verified, :error_text

  # Read/Write access to this attribute
  attr_writer :filename

  def initialize(filename = "")
    #puts "Got #{filename} as filename\n"
    load_file(filename)
  end
  def load_file(filename = "")
    if filename.nil?
      filename = ''
    end
    # Check the GPG signature
    if !filename.eql?('')
      $result = `/usr/bin/gpg --verify #{filename} < /dev/null > /dev/null 2>&1`
    end
    if File.exist?(filename) && $? == 0
        @filename = filename
        open(filename) do |file|
          file.each {|line|
            #puts "Processing line: #{line}"
            if line =~ /^Mac address: (.*)$/
              @mac_address = $1
            elsif line =~ /^License Expiration: (.*)$/
              @license_expiration_date = $1.to_i
            elsif line =~ /^Ingress: (.*)$/
              @ingress = $1.eql?('enabled') ? true : false
            elsif line =~ /^Performance: (.*)$/
              @performance = $1.eql?('enabled') ? true : false
            end
          }
        end
        @error_text = ''
        @last_verified = Time.now.to_i
    else
      @mac_address = ''
      @license_expiration_date = 0
      @error_text = "License file corrupted"
      @ingress = false
      @performance = false
      @last_verified = Time.now.to_i
    end
  end
  def valid?
    if self.verified?
      return !self.expired?
    end
  end
  def expiration_date
    if self.verified?
      return Time.at(@license_expiration_date).strftime("%d %b %Y")
    end
  end
  def has_ingress?
    if self.verified?
      return @ingress
    end
  end
  def has_performance?
    if self.verified?
      return @performance
    end
  end
  def expired?
    if self.verified?
      system_mac_addresses = `/sbin/ifconfig | grep HWaddr | cut -c39-`.gsub("  \n", ' ').chomp.strip
      if system_mac_addresses =~ /#{@mac_address}/i
        return @license_expiration_date < Time.now.to_i
      else
        return true
      end
    else
      return true
    end
  end
  def warning?
    if self.verified?
      return @license_expiration_date < (Time.now + 7.days).to_i
    else
      return true
    end
  end
  def verified?
    if Time.now.to_i < (@last_verified + 1.days).to_i
      # If we've verified the file in the last week, just
      # return true
      return true
    else
      # If we've haven't verified the file in the last week, 
      # reload the license
      load_file(self.filename)
      if Time.now.to_i < (@last_verified + 1.days).to_i
        return true
      else
        return false
      end
    end
  end
  def reset_verified
    @last_verified = (@last_verified - 20.years).to_i
  end
  def filename
    @filename
  end
  def filename=(filename)
    @filename = filename
    self.reset_verified
    self.verified?
  end
  def self.included(base)
    base.send :helper_method, :has_performance?, :has_ingress?
  end
end
