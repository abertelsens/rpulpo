

class PermitDecorator < ObjectDecorator

  def get_value(entity, table, field)
    puts "looking for #{table}.#{field} in #{entity}"
    begin
      case table
        when "people", "person"     then    entity[field]             unless entity.nil?
        when "permits"              then    entity.permit[field]      unless entity.permit.nil?
        else nil
      end
    rescue => error
      puts Rainbow("Warning: value of #{field} in table {table} could not be found").orange
      return nil
    end
  end


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
