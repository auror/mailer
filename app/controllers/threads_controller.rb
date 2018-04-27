class ThreadsController < ApplicationController

  def index
  end

  def create
    data = params[:thread]
    now = Time.now

    is_draft = data[:is_draft].present? ? true : false

    render status: 422, json: {:success => false, :error => 'No recipients'} and return if (is_draft and data[:to].blank?)

    email_body = data[:body]

    EmailThreadGroup.transaction do
      is_new = false
      if data[:tg_id].blank?
        thread_group = EmailThreadGroup.new(subject: data[:subject])
        thread_group.save!
        is_new = true
        type = 0
      else
        thread_group = EmailThreadGroup.find(data[:tg_id])
        type = EmailThread::Type.from(data[:type])
      end

      from = data[:from]
      to = data[:to].split(',')

      from_user = User.find(from)
      to_users = User.where(:email => to)
      to_user_emails = to_users.collect do |t|
        t.email
      end
      # to_.delete_if do |t|
      #   to_user_emails.exclude? t
      # end

      puts is_draft
      email = Email.new(sender: from_user.email, receivers: to_user_emails.join(','), body: email_body)
      email.save!

      ThreadsHelper.process_from_user(thread_group, from_user, is_new, email, is_draft, type)
      ThreadsHelper.process_to_users(thread_group, from_user, to_users, email, is_draft, type)
    end
    
    render status: 200, json: {success: true}
  end

  def get_mails
    type = params[:type]
    user = User.find(params[:user_id])
    page = params[:page].to_i
    page_size = 2
    
    label = Label.from type
    
    threads = EmailThread.joins(:email_thread_labels).where("email_threads.id = email_thread_labels.email_thread_id").where(email_thread_labels: {label_id: label.id, is_deleted: 0}, user_id: user.id).order("last_email_epoch desc").limit(page_size).offset(page_size * (page-1))
    
    # threads = EmailThread.where(user_id: user.id).order(:last_email_epoch).desc.limit(page_size).offset(page_size * (page-1))
    response = []
    threads.collect do |thread|
      data = {mails: [], tg_id: thread.email_thread_group_id, thread_id: thread.id, subject: EmailThread::Type.prefix(thread.thread_type) + thread.email_thread_group.subject}
      
      is_read = true
      
      mailboxes = Mailbox.where(:email_thread_id => thread.id, :is_deleted => 0)
      mailboxes.each do |mailbox|
        is_read = (is_read and mailbox.is_read)
        data[:mails] << {
            :from => mailbox.email.sender,
            :to => mailbox.email.receivers,
            :body => mailbox.email.body,
            :is_read => mailbox.is_read,
            :is_draft => mailbox.is_draft,
            :email_id => mailbox.email.id
        }
      end

      data[:is_read] = is_read

      response << data
    end

    puts response
    
    render json: response
  end

  def read
    thread = EmailThread.where(:email_thread_group_id => params[:id], :user_id => params[:u_id]).first

    Mailbox.where(:email_thread_id => thread.id).update(:is_read => true)

    render status: 200, json: {:success => true}
  end

  def destroy
    thread = EmailThread.where(:email_thread_group_id => params[:id], :user_id => params[:u_id]).first

    EmailThread.transaction do
      thread.email_thread_labels.each do |l|
        l.is_deleted = true
        l.save!
      end

      thread.labels << Label.find(Label::TRASH)
      thread.save!
    end
  end

  def send_draft
    thread_group = EmailThreadGroup.find(params[:tg_id])
    thread = thread_group.email_threads.where(user_id: params[:u_id]).first
    email = Email.find(params[:id])
    from_user = User.find(params[:u_id])
    to_users = User.where(:email => email.receivers.split(','))

    EmailThreadGroup.transaction do
      ThreadsHelper.send_to_users thread_group, from_user, to_users, email, true, thread.thread_type
    end
  end
end
