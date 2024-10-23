class Permits < ActiveRecord::Migration[7.1]
  def change
    create_table "permits" do |p|
      p.integer     :person_id
      p.string      :title
      p.string      :citizenship
      p.string      :passport
      p.boolean     :eu
      p.date        :border
      p.date        :expiry
      p.boolean     :picked
      p.string      :cf
      p.date        :team
      p.date        :ssn_registration
      p.date        :ssn_expiry
      p.string      :place
      p.date        :residence_letter
      p.date        :residence_registration
      p.string      :residence_notes
      p.string      :passport_notes
      p.string      :ssn_notes
      p.string      :permit_notes
      p.date        :first_permit
      p.date        :permit_certificate
      p.date        :permanent_permit_certificate
      p.date        :registry_cancellation
      p.string      :id_num
      p.date        :id_expiry
      p.date        :inspection
      p.date        :fingerprints
    end
  end
end
