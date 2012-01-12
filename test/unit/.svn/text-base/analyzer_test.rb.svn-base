require File.dirname(__FILE__) + '/../test_helper'
class AnalyzerTest < Test::Unit::TestCase
  fixtures :analyzers
  fixtures :switches
  fixtures :sites
  fixtures :switch_ports
  fixtures :config_params
  
  def test_site_generation
    site_count=Site.find(:all).length
    anl=Analyzer.create({:name => "Fake",:ip => '1.2.3.4',:start_freq => 10, :stop_freq=>100})
    assert !anl.id.nil?, "Failure Reason:" + anl.errors.full_messages.join(' | ')
    assert_equal Site.find(:all).length,site_count+1, "Expected #{site_count+1} sites to be created but only had #{Site.find(:all).length} created"
    assert !Analyzer.find(anl.id).nil?
    assert !anl.site_id.nil?, "Created analyzer cannot have a nil site"
    assert !anl.site.nil?, "Created analyzer cannot have a nil site"
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
  def test_freq_disp
    target_id=2
    anl=Analyzer.find(target_id)
    anl.start_freq_disp=5
    assert_equal anl.start_freq,5000000
    assert_equal anl.start_freq_disp,5
    anl.start_freq_disp=10
    assert_equal anl.start_freq,10000000
    assert_equal anl.start_freq_disp,10
    anl.stop_freq_disp=50
    assert_equal anl.stop_freq,50000000
    assert_equal anl.stop_freq_disp,50
    anl.stop_freq_disp=100
    assert_equal anl.stop_freq,100000000
    assert_equal anl.stop_freq_disp,100
  end
  def test_count
    assert_equal 5,Analyzer.count
  end
  def test_freq_range
    target_id=2
    anl=Analyzer.find(target_id)
    target_id=anl.id
    assert anl.update_attributes({:start_freq => 10, :stop_freq=> 1400000000})
    anl.save()
    anl=Analyzer.find(target_id)
    assert_equal 10,anl.start_freq

    anl=Analyzer.find(target_id)
    target_id=anl.id
    assert anl.update_attributes({:start_freq => 1000000000,  :stop_freq=> 1400000000})
    anli=Analyzer.find(target_id)
    assert_equal 1000000000,anl.start_freq

    anl=Analyzer.find(target_id)
    target_id=anl.id
    assert !anl.update_attributes({:start_freq => 2000000000, :stop_freq=> 1400000000}) #Start freq cannot be greater than 1.5Ghz
    anl=Analyzer.find(target_id)
    assert_equal 1000000000,anl.start_freq

    anl=Analyzer.find(target_id)
    target_id=anl.id
    assert anl.update_attributes({ :start_freq => 10,:stop_freq => 10})
    anl.save()
    anl=Analyzer.find(target_id)
    assert_equal 10,anl.stop_freq

    anl=Analyzer.find(target_id)
    target_id=anl.id
    assert anl.update_attributes({ :start_freq => 10,:stop_freq => 1_000_000_000})
    anli=Analyzer.find(target_id)
    assert_equal 1000000000,anl.stop_freq

    anl=Analyzer.find(target_id)
    target_id=anl.id
    assert !anl.update_attributes({ :start_freq => 10,:stop_freq => 2_000_000_000}) #Stop freq cannot be greater than 1.5Ghz
    anl=Analyzer.find(target_id)
    assert_equal 1000000000,anl.stop_freq
    assert !anl.update_attributes({:start_freq => 700_000_000,:stop_freq => 600_000_000}) #Start freq cannot be larger than stop freq
    anl=Analyzer.find(target_id)
  end

  def test_analyzer_switches
    analyzer = ""
    assert_nothing_raised(ActiveRecord::RecordNotFound) do
      analyzer=Analyzer.find(1)
    end
    assert_equal 5, analyzer.switches.count
    
    assert_nothing_raised(ActiveRecord::RecordNotFound) do
      analyzer=Analyzer.find(2)
    end
    assert_not_nil(analyzer, "Unable to find analyzer with id 2")
    assert_equal 0, analyzer.switches.count

    assert_nothing_raised(ActiveRecord::RecordNotFound) do
      analyzer=Analyzer.find(5)
    end
    assert_not_nil(analyzer, "Unable to find analyzer with id 2")
    assert_equal 3, analyzer.switches.count
    
    assert_nothing_raised(ActiveRecord::RecordNotFound) do
      analyzer=Analyzer.find(3)
    end
    assert_not_nil(analyzer, "Unable to find analyzer with id 3")
    assert_equal 0, analyzer.switches.count
    
    assert_raises(ActiveRecord::RecordNotFound) do
       analyzer=Analyzer.find(10)
    end
  end
  def _test_analyzer_sets_iptables_port
    Analyzer.delete_all
    analyzer = Analyzer.new
    analyzer.ip = "1.2.3.4"
    analyzer.name = 'Analyzer1'
    assert analyzer.save, "ERROR:  Unable to save analyzer #{analyzer.ip} (ERROR: #{analyzer.errors.full_messages})"
    
    assert_nothing_raised(ActiveRecord::RecordNotFound) do
      analyzer = Analyzer.find_by_ip('1.2.3.4')
    end
    assert_equal('Analyzer1', analyzer.name)
    assert_equal('1.2.3.4', analyzer.ip)
    assert_not_nil(analyzer.iptables_port, "iptables_port should not be null on #{analyzer.ip}")
    assert_not_equal("unk", analyzer.iptables_port, "iptables_port should not be unk on #{analyzer.ip}")
  end
  def _test_analyzer_sets_iptables_port_first_available
    Analyzer.delete_all
		startPort=0
    assert_nothing_raised(ActiveRecord::RecordNotFound) do
      startPort = ConfigParam.find_by_name("Iptables Start Port").val.to_i
    end

    analyzer = Analyzer.new
    analyzer.ip = '1.2.3.4'
    analyzer.name = 'Analyzer1'
    assert analyzer.save, "ERROR:  Unable to save analyzer #{analyzer.ip} (ERROR: #{analyzer.errors.full_messages})"
    
    assert_nothing_raised(ActiveRecord::RecordNotFound) do
      analyzer = Analyzer.find_by_ip('1.2.3.4')
    end
    assert_equal('Analyzer1', analyzer.name)
    assert_equal(startPort, analyzer.iptables_port.to_i, "iptables_port for first analyzer should be #{startPort}")
  end
  def _test_analyzer_sets_iptables_port_in_order
    Analyzer.delete_all
		startPort=0
    assert_nothing_raised(ActiveRecord::RecordNotFound) do
      startPort = ConfigParam.find_by_name("Iptables Start Port").val.to_i
    end

    analyzer = Analyzer.new
    analyzer.ip = '1.2.3.4'
    analyzer.name = 'Analyzer1'
    assert analyzer.save, "ERROR:  Unable to save analyzer #{analyzer.ip} (ERROR: #{analyzer.errors.full_messages})"
    
    assert_nothing_raised(ActiveRecord::RecordNotFound) do
      analyzer = Analyzer.find_by_ip('1.2.3.4')
    end
    assert_equal('Analyzer1', analyzer.name)
    assert_equal(startPort, analyzer.iptables_port.to_i, "iptables_port for first analyzer should be #{startPort}")

    # Second analyzer should get startPort + 1
    analyzer2 = Analyzer.new
    analyzer2.ip = '1.2.3.5'
    analyzer2.name = 'Analyzer2'
    assert analyzer2.save, "ERROR:  Unable to save analyzer #{analyzer2.ip} (ERROR: #{analyzer2.errors.full_messages})"
    
    assert_nothing_raised(ActiveRecord::RecordNotFound) do
      analyzer2 = Analyzer.find_by_ip('1.2.3.5')
    end
    assert_equal('Analyzer2', analyzer2.name)
    assert_equal(sprintf("%d", startPort + 1).to_i, analyzer2.iptables_port.to_i, "iptables_port for second analyzer should be #{sprintf("%d", startPort + 1)}")

    # Third analyzer should get startPort + 2
    analyzer3 = Analyzer.new
    analyzer3.ip = '1.2.3.6'
    analyzer3.name = 'Analyzer3'
    assert analyzer3.save, "ERROR:  Unable to save analyzer #{analyzer3.ip} (ERROR: #{analyzer3.errors.full_messages})"
    
    assert_nothing_raised(ActiveRecord::RecordNotFound) do
      analyzer3 = Analyzer.find_by_ip('1.2.3.6')
    end
    assert_equal('Analyzer3', analyzer3.name)
    assert_equal(sprintf("%d", startPort + 2).to_i, analyzer3.iptables_port.to_i, "iptables_port for third analyzer should be #{sprintf("%d", startPort + 2)}")

    # Delete the third analyzer, new analyzer should get startPort + 2
    assert_nothing_raised(ActiveRecord::RecordNotFound) do
      analyzer3 = Analyzer.find_by_ip('1.2.3.6')
    end
    analyzer3.destroy

    analyzer4 = Analyzer.new
    analyzer4.ip = '1.2.3.6'
    analyzer4.name = 'Analyzer4'
    assert analyzer4.save, "ERROR:  Unable to save analyzer #{analyzer4.ip} (ERROR: #{analyzer4.errors.full_messages})"
    
    assert_nothing_raised(ActiveRecord::RecordNotFound) do
      analyzer4 = Analyzer.find_by_ip('1.2.3.6')
    end
    assert_equal('Analyzer4', analyzer4.name)
    assert_equal(sprintf("%d", startPort + 2).to_i, analyzer4.iptables_port.to_i, "iptables_port for fourth (after third deleted) analyzer should be #{sprintf("%d", startPort + 2)}")
  end
  def _test_analyzer_delete_removes_port_forward
    Analyzer.delete_all
		startPort=0
    assert_nothing_raised(ActiveRecord::RecordNotFound) do
      startPort = ConfigParam.find_by_name("Iptables Start Port").val.to_i
    end
    analyzer = Analyzer.new
    analyzer.ip = "1.2.3.4"
    analyzer.name = 'Analyzer1'
    assert analyzer.save, "ERROR:  Unable to save analyzer #{analyzer.ip} (ERROR: #{analyzer.errors.full_messages})"
    
    assert_nothing_raised(ActiveRecord::RecordNotFound) do
      analyzer = Analyzer.find_by_ip('1.2.3.4')
    end
    assert_equal('Analyzer1', analyzer.name)
    ports = Analyzer.hash_iptables_port
    assert_not_nil(ports[analyzer.iptables_port], "iptables_port #{analyzer.iptables_port} should be assigned to #{analyzer.ip}")
    assert_nil(ports[sprintf("%d", startPort + 2)], "iptables_port #{sprintf("%d", startPort + 2)} should be null")

    # Delete the analyzer, verify the port forward is removed
    analyzer.destroy
    ports = Analyzer.hash_iptables_port
    assert_nil(ports[analyzer.iptables_port], "iptables_port #{analyzer.iptables_port} should be null")
  end

#Taking out test because we are disabling iptables.
  def _test_analyzer_modify_port_forward
    Analyzer.delete_all
    analyzer = Analyzer.new
    analyzer.ip = "1.2.3.4"
    analyzer.name = 'Analyzer1'
    assert analyzer.save, "ERROR:  Unable to save analyzer #{analyzer.ip} (ERROR: #{analyzer.errors.full_messages})"
    
    assert_nothing_raised(ActiveRecord::RecordNotFound) do
      analyzer = Analyzer.find_by_ip('1.2.3.4')
    end
    assert_equal('Analyzer1', analyzer.name)
    assert_equal('1.2.3.4', analyzer.ip)
    assert_not_nil(analyzer.iptables_port, "iptables_port should not be null on #{analyzer.ip}")
    assert_not_equal("unk", analyzer.iptables_port, "iptables_port should not be unk on #{analyzer.ip}")

    # Modify the record and test again
    analyzer.ip = "1.2.3.5"
    assert analyzer.save, "ERROR:  Unable to save analyzer #{analyzer.ip} (ERROR: #{analyzer.errors.full_messages})"
    assert_nothing_raised(ActiveRecord::RecordNotFound) do
      analyzer = Analyzer.find_by_ip('1.2.3.5')
    end
    assert_equal('1.2.3.5', analyzer.ip)
    assert_not_nil(analyzer.iptables_port, "iptables_port should not be null on #{analyzer.ip}")
    assert_not_equal("unk", analyzer.iptables_port, "iptables_port should not be unk on #{analyzer.ip}")
  end
  def test_analyzer_unique_ip_address
    Analyzer.delete_all
    analyzer = Analyzer.new
    analyzer.ip = "1.2.3.4"
    
    analyzer.name = 'Analyzer1'
    assert analyzer.save, "ERROR:  Unable to save analyzer #{analyzer.ip} (ERROR: #{analyzer.errors.full_messages})"
    
    assert_nothing_raised(ActiveRecord::RecordNotFound) do
      analyzer = Analyzer.find_by_ip('1.2.3.4')
    end
    assert_equal('Analyzer1', analyzer.name)
    assert_equal('1.2.3.4', analyzer.ip)

    analyzer2 = Analyzer.new
    analyzer2.ip = "1.2.3.4"
    analyzer2.name = 'Analyzer2'
    assert !analyzer2.valid?, "Should get errors on saving analyzer with same IP"
    assert analyzer2.errors.invalid?(:ip)
    assert_equal "has already been taken", analyzer2.errors.on(:ip)
    analyzer2.ip = "1.2.3.5"
    assert analyzer2.save, "ERROR:  Unable to save analyzer2 #{analyzer2.ip} (ERROR: #{analyzer2.errors.full_messages})"
    
    assert_nothing_raised(ActiveRecord::RecordNotFound) do
      analyzer2 = Analyzer.find_by_ip('1.2.3.5')
    end
    assert_equal('Analyzer2', analyzer2.name)
    assert_equal('1.2.3.5', analyzer2.ip)
  end
  def test_analyzer_unique_name
    Analyzer.delete_all
    analyzer = Analyzer.new
    analyzer.ip = "1.2.3.4"
    analyzer.name = 'Analyzer1'
    assert analyzer.save, "ERROR:  Unable to save analyzer #{analyzer.ip} (ERROR: #{analyzer.errors.full_messages})"
    
    assert_nothing_raised(ActiveRecord::RecordNotFound) do
      analyzer = Analyzer.find_by_ip('1.2.3.4')
    end
    assert_equal('Analyzer1', analyzer.name)
    assert_equal('1.2.3.4', analyzer.ip)

    analyzer2 = Analyzer.new
    analyzer2.ip = "1.2.3.5"
    analyzer2.name = 'Analyzer1'
    assert !analyzer2.valid?, "Should get errors on saving analyzer with same name"
    assert analyzer2.errors.invalid?(:name)
    assert_equal "has already been taken", analyzer2.errors.on(:name)
    analyzer2.name = "Analyzer2"
    assert analyzer2.save, "ERROR:  Unable to save analyzer2 #{analyzer2.ip} (ERROR: #{analyzer2.errors.full_messages})"
    
    assert_nothing_raised(ActiveRecord::RecordNotFound) do
      analyzer = Analyzer.find_by_ip('1.2.3.5')
    end
    assert_equal('Analyzer2', analyzer2.name)
    assert_equal('1.2.3.5', analyzer2.ip)
  end
  def test_get_switch_port
    anl=Analyzer.find(1)
    assert_equal 80,anl.get_switch_port(1)
    assert_equal 15,anl.get_switch_port(16)
    assert_equal 31,anl.get_switch_port(32)
    assert_equal 63,anl.get_switch_port(64)
    assert_equal 64,anl.get_switch_port(65)
    assert_equal 79,anl.get_switch_port(80)
    anl=Analyzer.find(5)
    assert_equal 100,anl.get_switch_port(1)
    assert_equal 120,anl.get_switch_port(17)
  end

  def test_errcode_lookup
    assert_equal "Switch Error.",Analyzer.errcode_lookup(240)
    assert_equal "RPTP Select Error.",Analyzer.errcode_lookup(241)
    assert_equal "Disk is full.",Analyzer.errcode_lookup(254)
  end
  def test_get_all_sites
     anl=Analyzer.find(1)
     assert_equal 16,anl.get_all_sites().length
     anl=Analyzer.find(2)
     assert_equal 1,anl.get_all_sites().length
     anl=Analyzer.find(3)
     assert_equal 1,anl.get_all_sites().length
     anl=Analyzer.find(4)
     assert_equal 1,anl.get_all_sites().length
  end
end
