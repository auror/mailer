module ThreadsHelper

  def self.process_from_user(thread_group, from_user, is_new, email, is_draft, type)
    thread = nil
    thread = EmailThread.where(:user_id => from_user.id, :email_thread_group_id => thread_group.id).first if !is_new

    curr_email = email

    if thread.blank?
      thread = EmailThread.new(thread_type: type, :email_thread_group_id => thread_group.id)

      from_user.email_threads << thread
      from_user.save!
    end

    mailbox = Mailbox.new(:email_thread_id => thread.id)

    if is_draft
      count = thread.labels.count do |label|
        label.id.eql? Label::DRAFTS
      end

      thread.labels << Label.find(Label::DRAFTS) if count.eql? 0
      mailbox.is_draft = 1
    else
      count = thread.labels.count do |label|
        label.id.eql? Label::SENT
      end

      thread.labels << Label.find(Label::SENT) if count.eql? 0
      thread.last_email_epoch = curr_email.created_at
    end

    mailbox.is_read = true

    curr_email.mailboxes << mailbox
    thread.mailboxes << mailbox

    mailbox.save!
    curr_email.save!

    thread.save!
  end

  def self.process_to_users(thread_group, from_user, to_users, email, is_draft, type)
    type_email = nil

    return if is_draft

    send_to_users(thread_group, from_user, to_users, email, is_draft, type)
  end

  def self.send_to_users(thread_group, from_user, to_users, email, is_draft, type)
    to_user_emails = to_users.collect do |t|
      t.email
    end

    from_user_thread = EmailThread.where(:user_id => from_user.id, :email_thread_group_id => thread_group.id).first

    to_users.each do |user|
      thread = nil
      thread = EmailThread.where(:user_id => user.id, :email_thread_group_id => thread_group.id).first if !type.eql?(EmailThread::Type::NEW)

      curr_email = email

      if thread.blank?
        thread = EmailThread.new(thread_type: type, :email_thread_group_id => thread_group.id)

        user.email_threads << thread
        user.save!

        if !type.eql?(EmailThread::Type::NEW)
          if type_email.nil?
            type_email = Email.new(sender: from_user.email, receivers: to_user_emails.join(','))
            from_user_thread_mails = Mailbox.where(:email_thread_id => from_user_thread.id).order("created_at desc")
            type_email.body = (Email.find(from_user_thread_mails.collect {|m| m.email_id}).collect {|e| e.body}).join("<br/> <br/>")
            type_email.save!
          end

          curr_email = type_email
        end
      end

      mailbox = Mailbox.new(:email_thread_id => thread.id)

      if is_draft and from_user_thread.mailboxes.where(is_deleted: 0, is_draft: 1).count.eql? 1
        from_user_thread.email_thread_labels.where(is_deleted: 0, label_id: Label::DRAFTS).each do |l|
          l.is_deleted = 1
          l.save!
        end
      end

      count = thread.labels.count do |label|
        label.id.eql? Label::INBOX
      end

      thread.labels << Label.find(Label::INBOX) if count.eql? 0

      curr_email.mailboxes << mailbox
      thread.mailboxes << mailbox

      mailbox.save!
      curr_email.save!

      thread.last_email_epoch = curr_email.created_at
      thread.save!
    end
  end
end