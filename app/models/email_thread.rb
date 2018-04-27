class EmailThread < ApplicationRecord

  module Type
    NEW = 0
    REPLIED = 1
    FORWARDED = 2

    def self.from type
      case type
        when 1
          return REPLIED
        when 2
          return FORWARDED
        else
          return NEW
      end
    end

    def self.prefix type
      case type
      when 1
        return "Re: "
      when 2
        return "Fwd: "
      else
        return ""
      end
    end
  end

  # attr_accessor :id, :type, :last_email_epoch, :user_id, :email_thread_group_id

  belongs_to :email_thread_group

  belongs_to :user

  has_many :email_thread_labels

  has_many :labels, through: :email_thread_labels

  has_many :mailboxes

end
