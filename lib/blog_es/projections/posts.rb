module Blog::Projections
  Post = Struct.new(:id, :title, :body, :written_at, :comments, :pending_comments) do
    def comment_count
      comments.length
    end
  end

  Author = Struct.new(:name, :email)

  Comment = Struct.new(:id, :body, :author, :written_at, :accepted_at)

  class Posts
    def initialize(store)
      @store = store
    end

    def handle_event(event)
      case event.name
      when :post_written
        add_post(event)
      when :post_commented
        add_comment_to_post(event)
      when :post_comment_accepted
        accept_comment(event)
      when :post_comment_rejected
        reject_comment(event)
      end

      self
    end

    def add_post(event)
      post = Post.new
      post.id = event.receiver_id
      post.title = event.get(:title)
      post.body = event.get(:body)
      post.written_at = event.occurred_on
      post.comments = []
      post.pending_comments = []
      store(post)
    end

    def add_comment_to_post(event)
      post = @store.get(event.receiver_id)
      comment = Comment.new
      comment.id = "#{post.id}/comments/#{event.get(:comment_id)}"
      comment.body = event.get(:body)
      comment.author = Author.new(event.get(:name), event.get(:email))
      comment.written_at = event.occurred_on
      post.pending_comments << comment
      store(post)
    end

    def accept_comment(event)
      post = load_from(event)
      target_id = "#{post.id}/comments/#{event.get(:comment_id)}"
      post.pending_comments.reject! do |comment|
        if comment.id == target_id
          comment.accepted_at = event.occurred_on
          post.comments << comment
          true
        end
      end
      store(post)
    end

    def reject_comment(event)
      post = load_from(event)
      target_id = "#{post.id}/comments/#{event.get(:comment_id)}"
      post.pending_comments.reject! do |comment|
         comment.id == target_id
      end
      store(post)
    end

    def load_from(event)
      @store.get(event.receiver_id)
    end

    def store(post)
      @store.set(post.id, post)
    end
  end

end
