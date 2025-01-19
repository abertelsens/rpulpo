# ARDecorator: A utility class to add functionality to AR models through a decorator pattern.

class ARDecorator

  # TEST METHODS
  # --------------------------------------------------------------------------------------------------------------------
  # Checks if a value is a boolean (true or false).
  is_boolean 				= proc { |value| value.is_a?(TrueClass) || value.is_a?(FalseClass) }

  # ACTION METHODS
  # --------------------------------------------------------------------------------------------------------------------
  # Converts boolean values to symbols (✓ for true, empty string for false).
  boolean_decorator = proc { |value| value ? "\u2714".encode('utf-8') : "" }

  # Formats a Date value into "DD-MM-YY".
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
    puts "calling constructor with element #{element.inspect}"
    @element = element
    @processors = []
    @att_methods = []
    @humanize_enums = true

    return if options.empty?

    options.each do |option|
      opt = OPTIONS[option]
      if opt
        puts "registering option #{opt.inspect}"
        register opt[:test], opt[:action]
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
  def register(test_method, action_method)
    @processors << [test_method, action_method]
  end

  # Registers a test method and an action method to be applied on attributes.
  def register_attribute(att, action_method)
    att = att.to_sym if att.is_a?(String)
    @att_methods << [att, action_method]
  end

  # Retrieves the value of an attribute, applying registered transformations if necessary.
  def get_attribute(attribute_identifier)
    if @element.is_a?(Enumerable)
      element_decorator = self.dup()
      return @element.map{|elem| element_decorator.set_element(elem).get_attribute(attribute_identifier) }
    end

    attribute_identifier = attribute_identifier.to_s if attribute_identifier.is_a?(Symbol)
    return nil if attribute_identifier.nil?

    if attribute_identifier.is_a?(Array)
      return attribute_identifier.map { |att| get_attribute(att) }
    end

    # Handle special cases for Proc and Array attributes.
    value =
      if attribute_identifier.is_a?(Proc)
        get_value_of_proc(attribute_identifier)
      else
        # Handle string-based attributes or related attributes.
        case attribute_identifier
          when method(:is_related_attribute?) then related_attribute(attribute_identifier)
          when String then @element[attribute_identifier.to_sym]
        end
      end

    if !attribute_identifier.is_a?(Proc)
      # Resolve the model and attribute for further processing.
      model, attribute = resolve_model_and_attribute(attribute_identifier)
      return nil if model.nil?
    end


    # Apply registered processors in sequence, including enum handling if applicable.
    @processors.inject(value) do |val, (test, action)|
      puts "ckecking test on #{@element} attribute #{attribute} #{val} test res: #{test.call(val)}"
      #uts "ckecking test on #{@element.family_name} attribute #{attribute} #{val} test res: #{test.call(val)}" if test.call(val)
      result = test.call(val) ? action.call(val) : val
      attribute_is_enum?(attribute) ? result.humanize.downcase : result
    end
  end

  # Calls a given Proc with the element as its argument.
  def get_value_of_proc(proc)
    proc.call(@element)
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

  # Checks if an attribute_identifier refers to a related attribute.
  def is_related_attribute?(attribute_identifier)
    return false unless attribute_identifier.is_a?(String)
    !attribute_identifier.split(".")[1].nil?
  end

  # Resolves and fetches the value of a related attribute.
  def related_attribute(attribute_identifier)
    model, attribute_name = resolve_model_and_attribute(attribute_identifier)
    puts "#{attribute_identifier} sendingig #{model.to_s.downcase.to_sym}"
    decorator = self.dup.set_element(@element.send(model.to_s.downcase.to_sym))
    puts "created decorator for related attribute. registered processors: #{decorator.processors.size}"
    decorator.get_attribute(attribute_name)
    #model ? model.get_attribute(attribute_name) : nil

  end

  # Determines the model and attribute name based on whether it's a related attribute.
  # It will return nil in case either the attribute_identifier is malformed.
  def resolve_model_and_attribute(attribute_identifier)
    attribute_identifier = attribute_identifier.to_s if attribute_identifier.is_a?(Symbol)
    if is_related_attribute?(attribute_identifier)
      model_name, attribute_name = attribute_identifier.split(".")
      puts "checnking model #{model_name} #{ (check_model model_name)}"
      (check_model model_name) ? (model = model_name.camelize.constantize) : (return nil)
    else
      model = @element.class
      attribute_name = attribute_identifier
    end
    puts "checnking attribute #{attribute_name} in model#{model} #{(check_attribute model, attribute_name)}"
    (check_attribute model, attribute_name) ? [model, attribute_name] : nil
  end

  # Verifies if a model exists within the associations of the current element.
  def check_model(model_name)
    res = (@element.class.reflect_on_all_associations.map{|assoc| assoc.name}).include? model_name.to_sym
    puts Rainbow("ARDecorator: unkown model #{model_name}.").orange unless res
    res
  end

  # Checks if a given attribute exists in the model.
  def check_attribute(model, attribute_name)
    !model.columns_hash[attribute_name].nil?
  end

  # Checks if an attribute corresponds to an enum.
  def attribute_is_enum?(attribute_name)
    @element.class.defined_enums.key?(attribute_name.to_s)
  end
end
