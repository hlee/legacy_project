# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def in_place_collection_editor_field(object,method,container, rec_id,default_value=nil)
    tag = ::ActionView::Helpers::InstanceTag.new(object, method, self)
    raise("Tag failure for object: #{object}") if tag.object.nil?()
    url = url_for( :action => "set_#{object}_#{method}", :id => rec_id )
    function =  "new Ajax.InPlaceCollectionEditor(" 
    function << "'#{method}_#{rec_id}'," 
    function << "'#{url}',"
    collection = container.inject([]) do |options, element|
      options << "[ '#{html_escape(element.last.to_s)}', '#{html_escape(element.first.to_s)}']" 
    end
    function << "{collection: [#{collection.join(',')}]" 
    function << "});" 

    javascript_tag(function)
  end
end
