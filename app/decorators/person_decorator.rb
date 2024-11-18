class PersonDecorator < ObjectDecorator

  def get_value(entity, table, field)
    begin
      case table
        when "people", "person"     then    entity[field]
        when "rooms"                then    entity.room[field]        unless entity.room.nil?
        when "personals"            then    entity.personal[field]    unless entity.personal.nil?
        when "studies"              then    entity.study[field]       unless entity.study.nil?
        when "crs_records"          then    entity.crs_record[field]  unless entity.crs_record.nil?
        when "matrices"             then    entity.matrix[field]      unless entity.matrix.nil?
        when "permits"              then    entity.permit[field]      unless entity.permit.nil?
        else nil
      end
    rescue => error
      puts Rainbow("Warning: value of #{field} in table {table} could not be found").orange
      return nil
    end
  end

  def html_cell(entity, sett)
    "<div class=\"#{sett.css_class}\"> #{decorate(get_value(entity, sett.table, sett.field_name),sett) }</div>"
  end

  def typst_value(entity, attribute, setting=nil)
    table, field = attribute.split(".")
    value = get_value(entity, table, field)
    value = (value.is_a? String) ? value.gsub("\"","'") : value
    if value.is_a?(Date)
      value = (setting=="latin") ? latin_date(value) : value.strftime("%d-%m-%y")
    end
    value = value.upcase if (setting=="upcase" && value!=nil)
    value.nil? ? "" : value.to_s

  end
end
