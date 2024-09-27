###########################################################################################
# A class defining a correo entry.
###########################################################################################
require 'rubyXL'

class Task < ActiveRecord::Base

  has_many :task_schedules

	# the default scoped defines the default sort order of the query results
	default_scope { order(name: :asc) }

  def self.create_update(params)
		puts "creating updating task wiht params #{params}"
		if params[:id]=="new"
			@task = Task.create(prepare_params params)
		else
			@task = Task.find(params[:id])
			@task.update(prepare_params params)
		end
    task_schedule_params = @task.map_task_schedules_params params
    task_schedules = TaskSchedule.create_from_array task_schedule_params
  end

	# creates an array of parameters that coan be used to create a TaslSchedule object
	def map_task_schedules_params(params)
		schedule_ids = params[:number].keys
		schedule_ids.map do |schedule_id|
			{
				schedule_id:  schedule_id,
				task:         self,
				number:       params[:number][schedule_id],
				s_time:       parse_time(params[:s_time][schedule_id]),
				e_time:       parse_time(params[:e_time][schedule_id]),
				notes:        params[:notes][schedule_id]
			}
		end
	end

	def self.prepare_params(params)
	{
		name: params[:name]
	}
	end

  def parse_time(time_string)
		DateTime.strptime(time_string,"%H:%M") unless time_string.blank?
  end

end
