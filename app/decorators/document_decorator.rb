
class DocumentDecorator < ObjectDecorator

  def html_cell(entity, sett)
    value =  case sett.table
      when "documents"  then entity[sett.get_field_name]
      when "pulpo_modules" then entity.pulpo_module[sett.get_field_name] unless entity.pulpo_module.nil?
      end
    "<div class=\"#{sett.css_class}\"> #{decorate(value,sett) }</div>"
  end
end
