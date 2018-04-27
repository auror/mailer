class EmailThreadGroup < ApplicationRecord

  # attr_accessor :id, :subject

  has_many :email_threads

end