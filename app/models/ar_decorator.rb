# ARDecorator: A utility class to add functionality to AR models through a decorator pattern.

# ----------------------------------------------------------------------------------------------------------------------
#
# author: alejandrobertelsen@gmail.com
# last major update: 2025-01-25
# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
# DESCRIPTION
#
# The ARDecorator class provides a way to add functionality to ActiveRecord models
# using the decorator pattern. It allows for the registration of value processors
# and attribute processors to modify the behavior of model attributes.
# ----------------------------------------------------------------------------------------------------------------------
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
  # @param element [Object] The element to be decorated.
  # @param options [Array<Symbol>] Optional processors to apply to the element.
  def initialize(element, *options)
    @element = element
    @value_processors = []
    @attribute_processors = {}
    @humanize_enums = true
    register_options options unless options.nil?
  end

  # Registers options for value processors.
  # @param options [Array<Symbol>] The options to register.
  def register_options(options)
    options.each do |option|
      if (opt = OPTIONS[option])
        register_value_processor opt[:test], opt[:action]
      else
        puts Rainbow("ARDecorator: unknown option '#{option}'. Ignoring it.").orange
      end
    end
  end

  # Sets the element to be decorated.
  # @param element [Object] The element to be decorated.
  # @return [ARDecorator] The decorator instance.
  def set_element(element)
    @element = element
    return self
  end

  # Registers a test method and an action method to be applied on attributes.
  # @param test_method [Proc] The test method to determine if the action should be applied.
  # @param action_method [Proc] The action method to apply to the attribute.
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

  def run_attribute_processors(attribute, value)
    # Apply registered processors in sequence, including enum handling if applicable.
    return value if attribute.is_a?(Proc)
    if @attribute_processors.key? attribute.to_sym
      value = @attribute_processors[attribute.to_sym].inject(value){|res,meth| meth.call(res)}
    end
    value
  end

  # Retrieves the value of an attribute, applying registered transformations if necessary.
  # @param attribute_identifier [String] The identifier of the attribute.
  # @return [Object] The processed value of the attribute.
  def get_attribute(attribute_identifier)
    puts "getting attribute #{attribute_identifier} for #{@element.inspect}"
    # if the element is really an enumerable object we return a map for each element
    if @element.is_a?(Enumerable)
      decorator = self.dup
      return @element.map { |elem| decorator.set_element(elem).get_attribute(attribute_identifier) }
    # if the identifier is an array we return a map of each attribute
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
    value = run_attribute_processors(attribute_identifier, value)
    value = run_value_processors(value)
    attribute_is_enum?(attribute_identifier) && value ? value&.humanize&.downcase : value
  end

  # Handles the retrieval of attribute values, including related attributes.
  # @param attribute_identifier [String] The identifier of the attribute.
  # @return [Object, nil] The value of the attribute or nil if not found.
  def get_value_of_attribute(attribute_identifier)
    if is_related_attribute?(attribute_identifier)
      model_name, attribute_name = attribute_identifier.split(".")
      if model_exists?(model_name)
        decorator = self.dup.set_element(@element.send(model_name.to_sym))
        decorator.get_attribute(attribute_name)
      else
        log_unknown_model(model_name)
        nil
      end
    else
      attribute_exists = @element.class.columns_hash.has_key?(attribute_identifier)
      attribute_exists ? @element[attribute_identifier.to_sym] : log_unknown_attribute(attribute_identifier)
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

  private

  # Checks if a related model exists.
  # @param model_name [String] The name of the model.
  # @return [Boolean] True if the model exists, false otherwise.
  def model_exists?(model_name)
    @element.class.reflect_on_all_associations.map(&:name).include?(model_name.to_sym)
  end


  # Logs an unknown model error message.
  # @param model_name [String] The name of the model.
  def log_unknown_model(model_name)
    puts Rainbow("ARDecorator: unknown model #{model_name}.").orange
  end

  # Logs an unknown attribute error message.
  # @param attribute_identifier [String] The identifier of the attribute.
  # @return [nil] Always returns nil.
  def log_unknown_attribute(attribute_identifier)
    puts Rainbow("ARDecorator: unknown attribute #{attribute_identifier}.").orange
    nil
  end


end
