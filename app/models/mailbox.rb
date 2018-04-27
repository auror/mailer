class Mailbox < ApplicationRecord

  # attr_accessor :id, :is_read, :email_thread_id

  belongs_to :email

  belongs_to :email_thread
end