# matrix_settings.rb
#---------------------------------------------------------------------------------------
# FILE INFO

# autor: alejandrobertelsen@gmail.com
# last major update: 2024-09-25
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# DESCRIPTION

# This file defines the model of a persons availability for matrix tasks.
#---------------------------------------------------------------------------------------
class Matrix < ActiveRecord::Base

  belongs_to  :person
  has_many    :tasks_available,   dependent: :destroy

  # enables the creation/update of the association model_users via attributes.
	# See the the prepare_params method.
	accepts_nested_attributes_for :tasks_available, allow_destroy: true

  #---------------------------------------------------------------------------------------
  # CRUD METHODS
  #---------------------------------------------------------------------------------------

  def self.prepare_params(params, matrix=nil)
    attributes = {
			person_id:    params["person_id"].to_i,
			choir: 	      params["choir"]!=nil,
			driver: 	    params["driver"]!=nil
    }
    # if we we are updating a person period then we update the tasks available
    attributes[:tasks_available_attributes] = Matrix.prepare_tasks_available_attributes(params,(matrix.nil? ? nil : matrix))
    attributes
	end

    def self.prepare_tasks_available_attributes(params, matrix=nil)
    # get the tasks available
    puts "got params #{params}"
    new_available_tasks_array = params[:task].values.map{|task_id| task_id.to_i}
    if matrix
      old_tasks_available = matrix.tasks_available.map{|ta| {ta.task_id => ta.id} }.inject(:merge)
      old_tasks_available_array = old_tasks_available.keys
      tasks_to_create = (new_available_tasks_array-old_tasks_available_array)
      destroy_attributes = (old_tasks_available_array - new_available_tasks_array).map do |task_id|
        {
          id:       old_tasks_available[task_id],
          _destroy: true
        }
      end
    else
      tasks_to_create = new_available_tasks_array
      destroy_attributes = []
    end
    create_attributes = tasks_to_create.map {|task_id| { task_id: task_id } }
    create_attributes + destroy_attributes
  end

  def self.create(params)
    pp = super(Matrix.prepare_params params)
  end

  def update(params)
    super(Matrix.prepare_params params, self)
  end


end #class end



class TasksAvailable < ActiveRecord::Base

  belongs_to  :matrix
  belongs_to  :task
  self.table_name = "tasks_available"

end
