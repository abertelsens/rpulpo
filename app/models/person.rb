###########################################################################################
# DESCRIPTION
# A class defininign a user object.
###########################################################################################

#A class containing the Users data
class Person < ActiveRecord::Base


    CAVABIANCA = "cavabianca"
    CTR_DEPENDIENTE = "ctr dependiente"
    NO_HA_LLEGADO = "no ha llegado"
    SE_HA_IDO = "se ha ido"
    LIVES_OPTIONS = [CAVABIANCA,CTR_DEPENDIENTE,NO_HA_LLEGADO, SE_HA_IDO]

    LAICO="laico"
    DIACONO="diácono"
    SACERDOTE="sacerdote"
    STATUS_OPTIONS = [LAICO, DIACONO,SACERDOTE ]

    NUMERARIO="n"
    AGREGADO="agd"
    N_AGD_OPTIONS = [NUMERARIO, AGREGADO]


	#belongs_to 	:department
	#has_many 	:transactions

	#validates   :department, 	presence: true
    
    ##########################################################################################
	# CALLBACKS
	##########################################################################################
	
	# after a transaciton is saved we make sure to update the balance in the related report
	# Chashbox overrides this method.
	before_save do |transaction|
		self.full_info = "#{(title.nil? ? "" : title+" ")}#{first_name} #{family_name} #{group}"
        self.full_name = "#{family_name} #{first_name}"
	end

    def self.update_full_info
        
        Person.all.each do |p|
            info = "#{(p.title.nil? ? "" : p.title+" ")} #{p.first_name} #{p.family_name}"
            p.update(full_info: info )
        end
    end

    def self.create_from_params(params)
        Person.create Person.prepare_params params
    end

    def self.search(search_string)
        if (Person.composite_query search_string)
            sql = "Select * from people WHERE #{Person.parse_query search_string}"
            Person.find_by_sql(sql)
            #return Person.where("\"#{Person.parse_query search_string}\"").order(family_name: :asc)
        else
            return Person.where("full_info ILIKE ?", "%#{search_string}%").order(family_name: :asc)
        end
    end

    def self.composite_query search_string
        !(search_string.scan /(\w+:\w+)+/).empty?
    end

    def self.parse_query(search_string)
        match = search_string.scan /(\w+:\w+)+/
        return nil if match.nil?
        qry = []
        match.each do |m|  
            t = m[0].split(":")
            qry << {att: t[0], value: t[1]}
        end
        puts "parsed query string"
        puts qry.to_s.yellow
        Person.query_array_to_s(qry)
    end

    def self.query_array_to_s(qry_array)
        s = ""
        qry_array.each_with_index do |q,index| 
            s << "people.#{q[:att]} ILIKE '%#{q[:value]}%'"
            s << " OR " if index+1<qry_array.size()
        end
        puts s.red
        return s
    end
    
    def update_from_params(params)
        update Person.prepare_params params
    end

    def self.prepare_params(params)
        puts "lives: #{params[:lives]}".red
        {
            title:          params[:title],
            first_name:     params[:first_name],
            family_name:    params[:family_name],
            short_name:     params[:short_name],
            nominative:     params[:nominative],
            accussative:    params[:accussative],
            arrived:        params[:arrived],
            group:          params[:group],
            lives:          params[:lives],
            arrival:        params[:arrival].blank? ? nil : Date.parse(params[:arrival]),
            departure:      params[:departure].blank? ? nil : Date.parse(params[:departure]),
            clothes:        params[:clothes],
            year:           params[:year],
            birth:          params[:birth].blank? ? nil : Date.parse(params[:birth]),
            celebration_info: params[:celebration_info],
            email:          params[:email],
            phone:          params[:phone],
            n_agd:          params[:n_agd],
            status:         params[:status],
        }
    end
    
    def self.get_attributes
        [
        {att_symb: :title,          value: "att"     ,set_edit: true,        name: "title",        description: "don, Fr., etc..."},  
        {att_symb: :first_name,     value: "att",    set_edit: false,        name: "first name",    description: "first name"},  
        {att_symb: :family_name,    value: "att",    set_edit: false,        name: "family name",   description: "family name"},
        {att_symb: :full_name,      value: "att",    set_edit: false,        name: "full name",     description: "full name, ex. Alejandro Bertelsen Simonetti"},
        {att_symb: :short_name,     value: "att",    set_edit: false,        name: "short name",    description: "a shorter version of the full name, ex. Alejandro Bertelsen"},
        {att_symb: :arrival,        value: "att",    set_edit: false,        name: "arrival date",  description: "arrival date to cavabianca",      format: "date"},
        {att_symb: :departure,      value: "att",    set_edit: false,        name: "departure",     description: "departure date to cavabianca",    format: "date"},
        {att_symb: :group,          value: "att",    set_edit: true,         name: "group",         description: "group in cavabianca"},
        {att_symb: :email,          value: "att",    set_edit: false,        name: "email",         description: "email"},
        {att_symb: :phone,          value: "att",    set_edit: false,        name: "phone",         description: "phone number"},
        {att_symb: :birth,          value: "att",    set_edit: false,        name: "birthday",      description: "birthday",    format:"date"},
        {att_symb: :celebration_info, value: "att",  set_edit: false,        name: "celebra",       description: "cuando celebra"},
        {att_symb: :lives,          value: "att",  set_edit: true,           name: "vive en",       description: "ctr donde vive"},
        {att_symb: :status,         value: "att",  set_edit: true,           name: "status",        description:  "laico/diácono/sacerdote"},
        {att_symb: :n_agd,          value: "att",  set_edit: true,           name: "n/agd",        description:  "n/agd"},
        {att_symb: :year,           value: "att",  set_edit: true,           name: "year",        description:  "año en cavabianca"},
        ]
    end

    def self.get_set_edit_attributes
        Person.get_attributes.filter {|att| att[:set_edit]}
    end    
    
    def get_status
        case self.status
            when LAICO then "laico"
            when DIACONO then "diácono"     
            when SACERDOTE then "sacerdote"     
        end
    end

    def get_lives
        case self.lives
            when CAVABIANCA then "cavabianca"
            when CTR_DEPENDIENTE then "ctr dependendiente"     
            when NO_HA_LLEGADO then "no ha llegado"     
        end
    end

    def get_n_agd
        case n_agd
            when NUMERARIO then "n"
            when AGREGADO then "agd"         
        end
    end


    def to_array(attributes)
        attributes.map {|att| self.att}
    end

    def can_be_deleted?
        true
    end

    def get_lives
        return "---" if lives.blank?
        return lives if lives==CTR_DEPENDIENTE
        return "#{lives} (#{group})" if lives==CAVABIANCA && !group.blank?
        lives
    end

end