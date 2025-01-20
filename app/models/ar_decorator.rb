# ARDecorator: A utility class to add functionality to AR models through a decorator pattern.

class ARDecorator

  # METHODS
  # --------------------------------------------------------------------------------------------------------------------
  # Checks if a value is a boolean (true or false).
  is_boolean 				= proc { |value| value.is_a?(TrueClass) || value.is_a?(FalseClass) }
  boolean_decorator = proc { |value| value ? "\u2714".encode('utf-8') : "" }
  decorate_date     = proc { |date| date.strftime("%d-%m-%y") }

  # OPTIONS: Defines test processors and their corresponding decorators for specific attributes.
  OPTIONS = {
    boolean_checkmark:  {test: is_boolean,                      action: boolean_decorator },
    default_date:       {test: ->(date) { date.is_a?(Date) },   action: decorate_date     },
    clean_strings:      {test: ->(s) { s.is_a?(String) },       action:  ->(s) { s.strip }}
  }

  attr_accessor :element, :processors

  # Constructor
  # Initializes the decorator with an element and optional processors to apply.
  def initialize(element, *options)
    @element = element
    @value_processors = []
    @attribute_processors = {}
    @humanize_enums = true
    register_options options unless options.nil?
  end

  def register_options(options)
    options.each do |option|
      if (opt = OPTIONS[option])
        register_value_processor opt[:test], opt[:action]
      else
        puts Rainbow("ARDecorator: unknown option '#{option}'. Ignoring it.").orange
      end
    end
  end

  def set_element(element)
    @element = element
    return self
  end

  # Registers a test method and an action method to be applied on attributes.
  def register_value_processor(test_method, action_method)
    @value_processors << [test_method, action_method]
  end

  def run_value_processors(value)
    # Apply registered processors in sequence, including enum handling if applicable.
    @value_processors.inject(value) do |val, (test, action)|
      test.call(val) ? action.call(val) : val
    end
  end
  
  # Registers a test method and an action method to be applied on attributes.
  def register_attribute_processor(attribute, action_method)
    if @attribute_processors.key? attribute.to_sym
      @attribute_processors[attribute.to_sym] << action_method
    else
      @attribute_processors[attribute.to_sym] = [action_method]
    end
  end
  

  def run_attribute_processors(attribute)
    # Apply registered processors in sequence, including enum handling if applicable.
    if @attribute_processors.key? attribute.to_sym
      @attribute_processors[attribute.to_sym].each do |meth|
        meth.call(val)
      end
    end
  end
  

  # Retrieves the value of an attribute, applying registered transformations if necessary.
  def get_attribute(attribute_identifier)
    # if the element is really an enumerable object we return a map for each element
    if @element.is_a?(Enumerable)
      decorator = self.dup()
      return @element.map{|elem| decorator.set_element(elem).get_attribute(attribute_identifier) }
    # if the identifier is an array we return a map of ech attrinbute
    elsif attribute_identifier.is_a?(Array)
      return attribute_identifier.map { |att| get_attribute(att) }
    end

    # make sure the identifier is a string
    return nil if attribute_identifier.nil?
    attribute_identifier = attribute_identifier.to_s if attribute_identifier.is_a?(Symbol)
    
    # Handle special cases for Proc and Array attributes.
    value =
      if attribute_identifier.is_a?(Proc)                
        attribute_identifier.call(@element)
      else
        get_value_of_attribute(attribute_identifier)
      end
    value = run_attribute_processors value
    value = run_value_processors value
    attribute_is_enum?(attribute_identifier) ? value.humanize.downcase : value
  end

  # handles only the cases of strings, they might be related attrinbutes or simple ones
  def get_value_of_attribute(attribute_identifier)
    
    if is_related_attribute?(attribute_identifier)  
      model_name, attribute_name = attribute_identifier.split(".")
      model_exists = (@element.class.reflect_on_all_associations.map{|assoc| assoc.name}).include? model_name.to_sym
      if model_exists
        decorator = self.dup.set_element(@element.send(model_name.to_sym))
        decorator.get_attribute attribute_name
      else
        puts Rainbow("ARDecorator: unkown model #{model_name}.").orange unless attribute_exists
       nil
      end

    # attribute is simple
    else
      attribute_exists = @element.class.columns_hash.has_key?(attribute_identifier)
      if attribute_exists then @element[attribute_identifier.to_sym] 
      else
        puts Rainbow("ARDecorator: unkown model #{model_name}.").orange unless attribute_exists
        nil
      end
    end
  end

  # Checks if an attribute_identifier refers to a related attribute.
  def is_related_attribute?(attribute_identifier)
    return false unless attribute_identifier.is_a?(String)
    !attribute_identifier.split(".")[1].nil?
  end
  
  # Checks if an attribute corresponds to an enum.
  def attribute_is_enum?(attribute_name)
    @element.class.defined_enums.key?(attribute_name.to_s)
  end


  # Joins the values of attributes into a comma-separated string (CSV format).
  def get_csv(att_array)
    get_attribute(att_array).join(", ")
  end

  # Joins the values of attributes into a tab-separated string (TSV format).
  def get_tsv(att_array)
    get_attribute(att_array).join("\t")
  end

  # Retrieves the values of specified attributes as an array.
  def to_array(attributes)
    attributes.map {|att| get_attribute att}
  end
end