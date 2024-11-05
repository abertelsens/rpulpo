class Questura < ActiveRecord::Migration[7.1]
  def change
    create_table "permits" do |p|
      p.integer     :person_id
      p.string      :title
      p.string      :citizenship
      p.string      :passport
      p.date        :passport_expiration
      p.date        :permit_expiration
      p.date        :pac
      p.date        :pac_signature
      p.date        :pac_validation
      p.date        :pusc_certificate_requested
      p.date        :pusc_certificate_received
      p.date        :permit_appointment
      p.date        :permit_fingerprints
      p.string      :notes
    end
  end
end
