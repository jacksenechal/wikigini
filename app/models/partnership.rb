class Partnership < ActiveRecord::Base
  belongs_to :person, :foreign_key => :partner_id
  after_create do |p|
    if !Partnership.find(:first, :conditions => { :partner_id => p.person_id })
      Partnership.create!(:person_id => p.partner_id, :partner_id => p.person_id)
    end
  end
  after_destroy do |p|
    reciprocal = Partnership.find(:first, :conditions => { :partner_id => p.person_id })
    reciprocal.destroy unless reciprocal.nil?
  end
end
