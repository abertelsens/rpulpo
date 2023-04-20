###########################################################################################
# DESCRIPTION
# A class defininign a user object.
###########################################################################################

#A class containing the Users data
class Person < ActiveRecord::Base

    CAVABIANCA = 1
    CTR_DEPENDIENTE = 2
    NO_HA_LLEGADO = 3

    LAICO=0
    DIACONO=1
    SACERDOTE=2

    NUMERARIO=0
    AGREGADO=1
    


	#belongs_to 	:department
	#has_many 	:transactions

	#validates   :department, 	presence: true
    
    ##########################################################################################
	# CALLBACKS
	##########################################################################################
	
	# after a transaciton is saved we make sure to update the balance in the related report
	# Chashbox overrides this method.
	before_save do |transaction|
        puts "callback called".red
		self.full_info = "#{(title.nil? ? "" : title+" ")}#{first_name} #{family_name}"
        self.full_name = "#{family_name} #{first_name}"
	end

    def self.create_from_params(params)
        Person.create Person.prepare_params params
    end

    def self.search(search_string)
        return Person.where("full_name ILIKE ?", "%#{search_string}%").order(family_name: :asc)
    end
    
    def update_from_params(params)
        update Person.prepare_params params
    end

    def self.prepare_params(params)
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
            teacher:        params[:teacher]=="true",
            birth:          params[:birth].blank? ? nil : Date.parse(params[:birth]),
            celebration_info: params[:celebration_info],
            email:          params[:email],
            phone:          params[:phone],
            n_agd:          params[:n_agd].to_i,
            status:         params[:status].to_i,
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
        {att_symb: :lives,            value: "method",  set_edit: true,         name: "vive en",       description: "ctr donde vive"},
        {att_symb: :status,           value: "method",  set_edit: true,         name: "status",        description:  "laico/diácono/sacerdote"},
        {att_symb: :n_agd,             value: "method",  set_edit: true,         name: "n/agd",        description:  "n/agd"},
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


end