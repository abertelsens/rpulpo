class Decorator

  CHECKMARK = "\u2714".encode('utf-8')

  def initialize(args=nil)
    return if args.nil?
    @table_settings   =   args[:table_settings] if args[:table_settings].present?
    @date_format      =   args[:date].present? ? args[:date] : "normal"

  end

  def decorate(value, setting)
    case setting.type
    when "boolean"  then  value ? CHECKMARK : ""
    when "enum"     then  value.humanize(capitalize: false) if value
    when "integer"  then  value
    when "date"     then  ((@date_format=="latin") ? latin_date(value) : value.strftime("%d-%m-%y")) unless value.nil?
    else  value
    end
  end

  def latin_date(date)
		Utils::complete_latin_date date
  end

end

class ObjectDecorator < Decorator

  def html_row(entity)
    @table_settings.att.map{|sett| html_cell(entity,sett)}.join("\n")
  end

  def html_cell(entity, sett)
    value =  entity[sett.get_field_name]
    "<div class=\"#{sett.css_class}\"> #{decorate(value,sett) }</div>"
  end

  def to_csv(entity)
    values = @table_settings.att.map do |attribute|
      table, field = attribute.field.split(".")
      get_value(entity, table, field)
    end
    values.join("\t")
  end

  def to_array(entity)
    values = @table_settings.att.map do |attribute|
      table, field = attribute.field.split(".")
      decorate(get_value(entity, table, field), attribute)

    end
    values
  end

  def entities_to_csv(entities)
    headers = @table_settings.att.map{|ts| ts.name}.join("\t") << "\n"
    headers << entities.map{|entity| to_csv entity}.join("\n")
  end

end
