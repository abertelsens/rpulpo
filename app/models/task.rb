###########################################################################################
# A class defining a correo entry.
###########################################################################################
require 'rubyXL'

class Task < ActiveRecord::Base

  has_many :task_schedules

  # the paremeters contain hashes of the type schedule_id: time
  def update_task_schedules(number, s_time,e_time,notes)
    s_time.keys.each do |schedule_id|
      ts = task_schedules.find_by(schedule: schedule_id)
      # if none of the parameters is blank
      if (number[schedule_id]!=0 && s_time[schedule_id]!="" && e_time[schedule_id]!="")
        if ts.nil?
          TaskSchedule.create(
            schedule_id: schedule_id,
            task:self,
            number: number[schedule_id],
            s_time:  parse_string s_time[schedule_id],
            e_time:  parse_string e_time[schedule_id],
            notes: notes[schedule_id]
            )
        else
          ts.update(
            number: number[schedule_id],
            s_time:  parse_string s_time[schedule_id],
            e_time:  parse_string e_time[schedule_id],
            notes: notes[schedule_id]
          )
        end
      # if one of the parameters is blank
      else
        puts "some of the paramenters is blank"
        ts.destroy if !ts.nil?
      end
    end
  end

  def parse_time(time_string)
    DateTime.strptime(time_string,"%H:%M")
  end


end
