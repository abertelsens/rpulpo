class Documents < ActiveRecord::Migration[7.0]
  def change
    create_table :documents do |p|
      p.string        :name
      p.integer       :pulpo_module_id
      p.string        :description
      p.integer       :engine
      p.string        :path
      p.boolean       :template_variables
    end
  end
end
