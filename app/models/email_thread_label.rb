class EmailThreadLabel < ApplicationRecord

  # attr_accessor :id, :label_id, :email_thread_id

  belongs_to :label

  belongs_to :email_thread
end