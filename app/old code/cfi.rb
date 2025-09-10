class Cfi < ActiveRecord::Base

	has_many :persons
	belongs_to :person, dependent: :destroy

end #class end
