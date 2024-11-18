class RoomDecorator < ObjectDecorator

  def html_cell(entity, sett)
    value =  case sett.table
      when "rooms"  then entity[sett.get_field_name]
      when "people" then entity.person[sett.get_field_name] unless entity.person.nil?
      end
    "<div class=\"#{sett.css_class}\"> #{decorate(value,sett) }</div>"
  end
end
