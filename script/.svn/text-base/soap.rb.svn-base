require 'soap/wsdlDriver'

driver=SOAP::WSDLDriverFactory.new('http://10.0.0.39:80/services/wsdl/').create_rpc_driver
driver.GetInstruments().each { |inst|
  puts inst.inspect()
}
