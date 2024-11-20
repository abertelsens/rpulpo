class RoomDecorator < ObjectDecorator


  def get_value(entity, table, field)
    begin
      case table
        when "rooms"                then    entity[field]
        when "people", "person"     then    entity.person[field]             unless entity.person.nil?
        when "personals"            then    entity.person.personal[field]    unless entity.person&.personal.nil?
        when "studies"              then    entity.person.study[field]       unless entity.person&.study.nil?
        when "crs_records"          then    entity.person.crs_record[field]  unless entity.person&.crs_record.nil?
        when "matrices"             then    entity.person.matrix[field]      unless entity.person&.matrix.nil?
        when "permits"              then    entity.person.permit[field]      unless entity.person&.permits.nil?
        else nil
      end
    rescue => error
      puts Rainbow("Warning: value of #{field} in table {table} could not be found").orange
      return nil
    end
  end


  def html_cell(entity, sett)
    value =  case sett.table
      when "rooms"  then entity[sett.get_field_name]
      when "people" then entity.person[sett.get_field_name] unless entity.person.nil?
      end
    "<div class=\"#{sett.css_class}\"> #{decorate(value,sett) }</div>"
  end
end
