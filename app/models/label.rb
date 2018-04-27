class Label < ApplicationRecord
  INBOX   = 1
  SENT    = 2
  DRAFTS  = 3
  TRASH   = 4

  # atr_accessor :id, :description

  has_many :email_thread_labels

  has_many :email_threads, through: :email_thread_labels

  def self.from type
    id = 1
    case type
      when 'sent'
        id = 2
      when 'drafts'
        id = 3
      when 'trash'
        id = 4
    end

    Label.find(id)
  end
end
