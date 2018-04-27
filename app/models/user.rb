class User < ApplicationRecord

  # attr_accessor :id, :threads, :name

  has_many :email_threads

end