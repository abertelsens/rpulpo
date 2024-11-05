#require 'draper'



class Decorator

  CHECKMARK = "\u2714".encode('utf-8')
  MONTHS_LATIN = [nil, "ianuarii", "februarii", "martii", "aprilis", "maii", "iunii", "iulii", "augusti", "septembris", "octobris", "novembris", "decembris"]

  def initialize(args=nil)
    if args!=nil
      @table_settings =  args[:table_settings] if args[:table_settings].present?
      @date_format = args[:date].present? ? args[:date] : "normal"
    end
  end

  def decorate(value, setting)
    case setting.type
    when "boolean"  then  (CHECKMARK if value)
    when "enum"     then  value
    when "integer"  then  value
    when "date"     then  ((@date_format=="latin") ? latin_date(value) : value.strftime("%d-%m-%y")) unless value.nil?
    else  value
    end
  end

  def latin_date(date)
		"die #{date.day} mensis #{MONTHS_LATIN[date.month]} anni #{date.year}"
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

end

class RoomDecorator < ObjectDecorator

  def html_cell(entity, sett)
    value =  case sett.table
      when "rooms"  then entity[sett.get_field_name]
      when "people" then entity.person[sett.get_field_name] unless entity.person.nil?
      end
    "<div class=\"#{sett.css_class}\"> #{decorate(value,sett) }</div>"
  end
end

class PermitDecorator < ObjectDecorator

  def html_row(entity)
    return @table_settings.att.map{|sett| html_cell(entity,sett)}.join("\n") if (entity.permit.nil? || entity.permit.days_to_expire.nil?)
    days_to_expire = entity.permit.days_to_expire
    color_class = case
      when days_to_expire<0 then "danger-cell"
      when days_to_expire<60 then "warning-cell"
      else ""
    end
    @table_settings.att.map{|sett| html_cell(entity,sett,color_class)}.join("\n")
  end

  def html_cell(entity, sett,color_class=nil)
    value =  case sett.table
      when "people"  then entity[sett.get_field_name]
      when "permits" then entity.permit[sett.get_field_name] unless entity.permit.nil?
      end
    "<div class=\"#{sett.css_class} #{color_class}\"> #{decorate(value,sett) }</div>"
  end
end


class PersonDecorator < ObjectDecorator

  def get_value(entity, table, field)
    case table
      when "people", "person"     then    entity[field]
      when "rooms"                then    entity.room[field]        unless entity.room.nil?
      when "personals"            then    entity.personal[field]    unless entity.personal.nil?
      when "studies"              then    entity.study[field]       unless entity.study.nil?
      when "crs_records"          then    entity.crs_record[field]  unless entity.crs_record.nil?
      when "matrices"             then    entity.matrix[field]      unless entity.matrix.nil?
      when "permits"              then    entity.permit[field]      unless entity.permit.nil?
    end
  end

  def html_cell(entity, sett)
    "<div class=\"#{sett.css_class}\"> #{decorate(get_value(entity, sett.table, sett.field_name),sett) }</div>"
  end

  def typst_value(entity, attribute, setting=nil)
    table, field = attribute.split(".")
    value = get_value(entity, table, field)
    value = (value.is_a? String) ? res.gsub("\"","'") : value
    (setting=="latin" && value!=nil)? latin_date(value) : value
  end
end
