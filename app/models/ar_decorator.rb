class ARDecorator

  # TEST METHODS
  # --------------------------------------------------------------------------------------------------------------------
  is_boolean 				= proc { |value| value.is_a?(TrueClass) || value.is_a?(FalseClass) }

  # ACTION METHODS
  # --------------------------------------------------------------------------------------------------------------------
  boolean_decorator = proc { |value| value ? "\u2714".encode('utf-8') : "" }
  decorate_date     = proc { |date| date.strftime("%d-%m-%y") }

  OPTIONS = {
    boolean_checkmark:  {test: is_boolean,                      action: boolean_decorator },
    default_date:       {test: ->(date) { date.is_a?(Date) },   action: decorate_date     },
    clean_strings:      {test: ->(s) { s.is_a?(String) },       action:  ->(s) { s.strip }}
  }

  def initialize(element, *options)
    @element = element
    @methods = []
    @humanize_enums = true
    return unless options
    options.each do |option|
      puts "ARDeocrator: parsing option #{option}"
      opt = OPTIONS[option]
      if opt.nil?
        puts Rainbow("ARDecorator: unkown option #{option}. Ignoring it").orange
      else
        register OPTIONS[option][:test], OPTIONS[option][:action]
      end
    end
  end

  def register(test_method, action_method)
    @methods << [test_method, action_method]
  end

  def get_attribute(attribute)
    return nil if attribute.nil?
    return get_value_of_proc attribute if attribute.is_a?(Proc)
    return attribute.map{|att| get_attribute(att)} if attribute.is_a?(Array)

    if !check_attribute? attribute
      puts Rainbow("ARDecorator: unkown attribute #{attribute}. Ignoring it").orange
      return nil
    end

    value = case attribute
      when method(:is_related_attribute?)   then  related_attribute(attribute)
      when String                           then  @element[attribute.to_sym]
      else                                  @element[attribute]
      end

    # Apply the registered methods
    @methods.inject(value) do |val, (test, action)|
      res = test.call(value) ? action.call(value) : val
      if get_attribute_type(attribute)=="enum"
        res = res.humanize
      end
      res
    end
  end

  def get_value_of_proc(proc)
    proc.call(@element)
  end


  def get_csv(att_array)
    get_attribute(att_array).join(", ")
  end

  def get_tsv(att_array)
    get_attribute(att_array).join("\t")
  end


  private

  def check_attribute?(attribute_name)
    model, attribute_name = resolve_model_and_attribute attribute_name
    return false if model.nil?
    puts "model #{model} attribute_name #{attribute_name}"
    model.method_defined?(attribute_name.to_sym)
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

  def to_array(attributes)
    attributes.map {|att| get_attribute att}
  end

  def attribute_is_enum?(model_name, attribute)
    begin
      # Convert the lowercase model_name to a class
      model = model_name.camelize.constantize

      # Check if the attribute is an enum
      model.defined_enums.key?(attribute.to_s)
    rescue NameError
      # Return false if the model name is invalid
      false
    end
  end

  def get_attribute_type(attribute_name)
    return :proc unless attribute_name.is_a? String
    if is_related_attribute? attribute_name
      table, attribute_name = attribute_name.split(".")
      model_name = table.singularize
      model = model_name.camelize.constantize
    else
      model = @element.class
    end
    return :enum if attribute_is_enum? model, attribute_name
    model.columns_hash[attribute_name].type
  end


  def self.get_attribute_type(attribute_name)
    return :proc unless attribute_name.is_a?(String)

    model, attribute_name = resolve_model_and_attribute(attribute_name)
    return :enum if attribute_is_enum?(model, attribute_name)

    model.columns_hash[attribute_name]&.type
  end

  # Determines the model and attribute name based on whether it's a related attribute
  def resolve_model_and_attribute(attribute_identifier)
    puts "resolving name #{attribute_identifier}"
    if is_related_attribute?(attribute_identifier)
      model, att_name = attribute_identifier.split(".")
      begin
        Object.const_defined?(table)
      rescue
        puts Rainbow("ARDecorator: unkown attribute #{attribute_identifier}. Ignoring it").orange
        return [nil,nil]
      end
      model = table.singularize.camelize.constantize
      return [model,att_name]
    else
      return [@element.class, attribute_identifier]
    end

  end

  def attribute_is_enum?(model, attribute_name)
    @element.class.defined_enums.key?(attribute_name.to_s)
  end

end
