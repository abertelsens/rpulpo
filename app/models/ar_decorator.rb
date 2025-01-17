class ARDecorator
  
  is_boolean 				= proc { |value| value.is_a?(TrueClass) || value.is_a?(FalseClass) } 
  
  boolean_decorator = proc { |value| value ? "\u2714".encode('utf-8') : "" }
  decorate_date     = proc { |date| date.strftime("%d-%m-%y") }
  
  OPTIONS = {
    boolean_checkmark:  {test: is_boolean,                      action: boolean_decorator },
    default_date:       {test: ->(date) { date.is_a?(Date) },   action: decorate_date },
    clean_strings:      {test: ->(s) { s.is_a?(String) },       action:  ->(s) { s.strip } }
  }
  
  def initialize(element, *options)
    @element = element
    @methods = []
    return unless options
    options.each {|option| register OPTIONS[option][:test], OPTIONS[option][:action] } 
  end

  def register(test_method, action_method)
    @methods << [test_method, action_method]
  end
  
  def get_attribute(attribute)
    value = case attribute
      when Proc   then  attribute.call(@element)
      when method(:is_related_attribute?) then related_attribute(attribute)
      when String then  @element[attribute.to_sym]
      when Array  then  attribute.map{|att| get_attribute(att)}
      else              @element[attribute]
      end
  
    # Apply the registered methods
    @methods.inject(value) do |val, (test, action)|
      test.call(value) ? action.call(value) : val
    end
  end

  def is_related_attribute?(attribute_name)
    return false unless attribute_name.is_a?(String)
    !attribute_name.split(".")[1].nil?
  end

  def related_attribute(attribute_name)
    table, attribute = attribute_name.split(".")
    return nil if table.nil? || attribute.nil?
  
    # Singularize table name. If the table name is already in singular nothing will change
    singular_table = table.singularize
  
    # Ensure the @element responds to the relationship
    return nil unless @element.respond_to?(singular_table)
  
    # Fetch the related element
    related_element = @element.public_send(singular_table)
    return nil if related_element.nil?
    related_element[attribute]
  end

  def get_csv(att_array)
    get_attribute(att_array).join(", ")
  end
  
  def get_tsv(att_array)
    get_attribute(att_array).join("\t")
  end

  def to_array(attributes)
    attributes.map {|att| get_attribute att}
  end
end