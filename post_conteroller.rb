# a function for getting previous comments
def get_previous_post_comments
    forum_post_id = params[:forum_post_id]
    per_page = params[:per_page].to_i # Convert to integer
    page = params[:page].to_i

    # Load comments for the specified forum_post_id, sorted by created_at in descending order
    forum_post = ForumPost.find_by(forum_post_id: forum_post_id)

    if forum_post
      # Get the total number of comments
      total_comments = forum_post.post_comments.count

      # Calculate the total number of pages
      total_pages = (total_comments.to_f / per_page).ceil
      total_pages = 1 if total_pages <= 0

      # If the page is 0, set it to the total number of pages
      page = page.zero? ? total_pages : page

      comments = forum_post.post_comments.paginate(page: page, per_page: per_page)

      comment_details = comments.map do |comment|
        alumni = Alumni.find_by(alumni_id: comment.created_by)
        user = User.find_by(user_id: alumni.user_id)

        user = if alumni
                 {
                   first_name: user.first_name,
                   surname: user.surname,
                   # pic: user.profile_picture.attached? ? user.profile_picture : nil
                 }
               else
                 {
                   first_name: "",
                   surname: "",
                   pic: nil
                 }
               end

        {
          content: comment.comment,
          created_at: comment.created_at,
          created_by: comment.created_by,
          user: user,
        }
      end

      render json: {
        comments: comment_details,
        forum_post_id: forum_post_id,
        page: page
      }
    else
      render json: { error: 'Forum post not found' }, status: :not_found
    end
  end
