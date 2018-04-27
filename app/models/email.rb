class Email < ApplicationRecord

  # attr_accessor :id, :sender, :receivers, :body, :created_at

  has_many :mailboxes

end