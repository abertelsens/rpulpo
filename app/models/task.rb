###########################################################################################
# A class defining a correo entry.
###########################################################################################
require 'rubyXL'

class Task < ActiveRecord::Base

  has_many :task_schedules

  def self.create_update(params)
		@task = (params[:id]=="new" ? nil : Task.find(params[:id]))
		@task.nil? ? (@task = Task.create(prepare_params params)) : @task.update(prepare_params params)
    ts_params = @task.map_task_schedules_params params
    task_schedules = TaskSchedule.create_from_array(ts_params)
  end

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

	def self.destroy(params)
		Task.find(params[:id]).destroy
	end

  def parse_time(time_string)
    DateTime.strptime(time_string,"%H:%M")
  end

end
