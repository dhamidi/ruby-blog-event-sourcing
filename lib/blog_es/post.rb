class Blog::Post
  attr_reader :id

  def initialize(id)
    @id = id
    @written = false
    @comment_id = 1
    @comment_emails = {}
  end

  def handle_command(command)
    case command.name
    when :write_post
      write(command)
    when :edit_post
      edit(command)
    when :comment_on_post
      comment(command)
    when :reject_comment_on_post
      reject_comment(command)
    end
  end

  def handle_event(event)
    case event.name.to_sym
    when :post_written
      @written = true
    when :post_commented
      @comment_id = @comment_id + 1
      @comment_emails[event.get(:comment_id).to_i] = event.get(:email)
    end
  end

  def reject_comment(params)
    err = params.errors

    comment_id = params.get(:comment_id).to_i
    err.add(:comment_id, :not_found) if comment_id > @comment_id

    return err unless err.empty?

    email = @comment_emails.fetch(comment_id)

    return ::Blog::Event.new.with(:post_comment_rejected, {
                                    comment_id: params.get(:comment_id),
                                    email: email,
                                    reason: params.get(:reason) { "" },
                                  })
  end

  def comment(params)
    err = params.errors

    unless @written
      err.add(:id, :not_found)
    end

    name = params.get(:name) { "" }.to_s
    email = params.get(:email) { "" }.to_s
    body = params.get(:body) { "" }.to_s

    err.add(:name, :required) if name == ""
    err.add(:email, :required) if email == ""
    err.add(:body, :required) if body == ""

    return err unless err.empty?

    return Blog::Event.new.with(:post_commented, {
                                  comment_id: @comment_id,
                                  name: name,
                                  email: email,
                                  body: body,
                                })
  end

  def edit(params)
    err = params.errors

    unless @written
      err.add(:id, :not_found)
    end

    err.add(:title, :required) if params.get(:title).to_s { "" } == ""
    err.add(:body, :required)  if params.get(:body).to_s { "" } == ""

    if err.empty?
      return Blog::Event.new.with(:post_edited, {
                                    title: params.get(:title).to_s,
                                    body: params.get(:body).to_s,
                                    written_at: params.get(:now).to_s,
                                    id: params.get(:id).to_s,
                                  })
    else
      return err
    end
  end

  def write(params)
    err = params.errors

    err.add(:title, :required) if params.get(:title).to_s { "" } == ""
    err.add(:body, :required) if params.get(:body).to_s { "" } == ""

    if @written
      err.add(:id, :not_unique)
    end

    if err.empty?
      return Blog::Event.new.with(:post_written, {
                              title: params.get(:title).to_s,
                              body: params.get(:body).to_s,
                              written_at: params.get(:now).to_s,
                              id: params.get(:id).to_s,
                            })
    end

    return err
  end

end
