class Partner < ActiveRecord::Base
  belongs_to :person
  belongs_to :person, :foreign_key => :partner_id
end
