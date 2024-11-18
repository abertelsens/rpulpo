class ValidationErrorsDecorator < Decorator

  def initialize(errors_hash)
    @errors_hash = errors_hash
  end

  def to_html()
    return "" if @errors_hash.nil?
    prefix = "<i class='fa-solid fa-triangle-exclamation' style='display:inline;'></i>&nbsp"
    @errors_hash.keys.inject(prefix){|res,att| res << "<b>#{att.to_s.humanize(capitalize: false)}</b>: #{@errors_hash[att].join("-")} "}
  end
end
