###########################################################################################
# DESCRIPTION
# A Module wrapping some utility functions
# Last major modification 08-02-21
###########################################################################################

module Utils

	MONTHS_ROMAN 	= ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII"]
	MONTHS_LATIN 	= ["ianuarii", "februarii", "martii", "aprilis", "maii", "iuni", "iuli", "augusti", "septembris", "octobris", "novembris", "decembris"]
	NIS_UNICODE 	= "\u20AA"
	USD_UNICODE 	= "\u0024"
	EUR_UNICODE 	= "\u20AC"

	# returns a string from a float with comma separators
	def float2string(num)
		("%.2f" % sum).reverse.gsub(/(\d+\.)?(\d{3})(?=\d)/, '\\1\\2,').reverse
	end

	def float2percentage(num)
		num!= 0.0 ? ((num*100).round(1)).to_s + "%" : "---"
	end

	def float2currency(params)
		case params[:currency]
			when "USD" then currency = USD_UNICODE
			when "EUR" then currency = EUR_UNICODE
			else currency = NIS_UNICODE
		end
		decimals = params[:decimal]==nil ? 2 : params[:decimal]

		if params[:sum]!=0.0
			return "#{("%.#{decimals}f" % params[:sum]).reverse.gsub(/(\d+\.)?(\d{3})(?=\d)/, '\\1\\2,').reverse} #{currency}"
		else
			return "---"
		end
	end

	def array2csv a
		return a.join(",") + "\n"
	end

	def contry_name code
		return IsoCountryCodes.find(code).name
	end

	def date2string d
		return d.strftime("%d-%m-%y")
	end

	def dateFromCSV date_csv_string
		return Date.strptime(date_csv_string,"%Y-%m-%d")
	end

	def dateFromParams date_param
		return Date.strptime(date_param,"%d-%m-%y")
	end

	def get_class type
		return object_class = Object.const_get(CLASS_NAMES[type])
	end

	def trim(s)
		return s.gsub!(/\A"|"\Z/, '')
	end

	def columns(col, val)
		return "two.columns = val"
	end

	def latin_date(date)
		return "" if date.nil?
		date = date.strftime("%-d-%m-%Y") if date.is_a? Date
		date_array = date.split("-")
		"die #{date_array[0]} #{MONTHS_LATIN[date_array[1].to_i-1]} #{date_array[2]}"
	end

	def complete_latin_date(date)
		return "" if date.nil?
		date = date.strftime("%-d-%m-%Y") if date.is_a? Date
		date_array = date.split("-")
		year = date_array[2].to_i < 1000 ? "20#{date_array[2]}" : date_array[2]
		"Datum Romae, die #{date_array[0]} mensis #{MONTHS_LATIN[date_array[1].to_i-1]} anni #{year}"
	end


	def roman_month_date(date)
		date_array = date.split("-")
		year = date_array[2].to_i < 1000 ? "20#{date_array[2]}" : date_array[2]
		"#{date_array[0]}-#{MONTHS_ROMAN[date_array[1].to_i-1]}-#{year}"
	end

end
