class SfChannel < ActiveRecord::Base
  serialize :channel_dtls
  belongs_to :sf_system_file
  has_many :sf_test_channel, :dependent => :destroy
  def freq()
    if (channel_type == "0")
      puts channel_dtls.inspect;
      return channel_dtls['videofreq']
    else
      return channel_dtls['centerfreq']
    end
  end

  def modstr
    #Pulled from eModulation cm2000 code
    case channel_dtls["modulation"]
      when 0
        return "QPSK"
      when 1
        return "QAM64"
      when 2
        return "QAM128"
      when 3
        return "QAM256"
      when 4
        return "QAM16"
      when 5
        return "QAM32"
      when 6
        return "QPR"
      when 7
        return "FSK"
      when 8
        return "BPSK"
      when 9
        return "CW"
      when 10
        return "VSB_AM"
      when 11
        return "FM"
      when 12
        return "CDMA"
      when 100
        return "NTSC"
      when 101
        return "PAL_B"
      when 102
        return "PAL_G"
      when 103
        return "PAL_I"
      when 104
        return "PAL_M"
      when 105
        return "PAL_N"
      when 106
        return "SECAM_B"
      when 107
        return "SECAM_G"
      when 108
        return "SECAM_K"
      when 200
        return "OFDM"
      when 300
        return "UNKNOWN CHANNEL"
      else
        return "UNKNOWN"
    end
  end
end
