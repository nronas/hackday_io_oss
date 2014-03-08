class HacksController < ApplicationController

  before_filter :get_hack,         except: [:create, :index]
  before_filter :check_signed_in,  only:   [:upvote, :downvote]
  before_filter :check_permission, only:   [:edit, 
                                            :update, 
                                            :destroy, 
                                            :move_up_in_queue, 
                                            :move_down_in_queue, 
                                            :join_presentation, 
                                            :leave_presentation]
  has_mobile_fu

  def create
    # FIXME: gross
    hack = Hack.new(params[:hack])
    hack.contributors << current_user
    hack.hackday = Hackday.find(params[:hackday_id])

    if hack.save
      redirect_to hack
    else
      flash[:error] = hack.errors.full_messages.join(", ")
    end
  end

  def show
    @hack_comments = @hack.comments.where(:admin_comment => nil).order('created_at DESC').paginate(:page => params[:hack_comments_page] || 1, :per_page => 10)
    @hack_admin_comments = @hack.comments.where(:admin_comment => true).order('created_at DESC').paginate(:page => params[:hack_admin_comments_page] || 1, :per_page => 8)
  end

  def edit
  end

  def update
    @hack.update_attributes(params[:hack])
    if @hack.errors.any?
      flash[:error] = @hack.errors.full_messages.join(", ")
      redirect_to edit_hack_path(@hack)
    else
      flash[:message] = "Update successful!"
      redirect_to hack_path(@hack)
    end
  end

  def destroy
    if @hack.destroy
      flash[:message] = "Your hack has been destroyed. Please return your group number tag #{@hack.group_number} to the organizers."
      redirect_to @hack.hackday
    else
      flash[:error] = @hack.errors.full_messages.join(", ")
    end
  end

  def upvote
    if @hack.upvoted_by.include? current_user.id
      @hack.upvote(current_user)
      flash[:message] = "You have removed your vote."
    else
      @hack.upvote(current_user)
      flash[:message] = "You have cast your vote!"
    end
    redirect_to :back
  end

  def downvote
    if @hack.downvoted_by.include? current_user.id
      @hack.downvote(current_user)
      flash[:message] = "You have removed your vote."
    else
      @hack.downvote(current_user)
      flash[:message] = "You just voted down someone's hard work. You are a terrible person!"
    end
    redirect_to :back
  end

  def add_contribution
    if @hack.has_contributor?(current_user)
      flash[:error] = "You're already a contributor!"
    else
      @hack.add_contribution(current_user)
      flash[:message] = "We recognize you for your efforts, thank you for your service."
    end
    redirect_to :back
  end

  def remove_contribution
    unless @hack.has_contributor?(current_user)
      flash[:error] = "what are you doing? you aren't a contributor!"
    else
      @hack.remove_contribution(current_user)
      flash[:message] = "you are no longer a contributor :("
    end
    redirect_to :back
  end

  def finish_presentation
    @hack.hackday.leave_queue(@hack)
    flash[:message] = "This hack has been presented - congrats!"
    redirect_to :back
  end

  def move_up_in_queue
    if @hack.hackday.move_up_in_queue(@hack)
      flash[:message] = "Your hack has been moved up in the presentation queue."
    else
      flash[:error] = "Your hack is already at the top of the queue."
    end

    redirect_to :back
  end

  def move_down_in_queue
    if @hack.hackday.move_down_in_queue(@hack)
      flash[:message] = "Your hack has been moved down in the presentation queue."
    else
      flash[:error] = "Your hack is already the last one in the queue."
    end

    redirect_to :back
  end

  def join_queue
    @hack.hackday.join_queue(@hack)
    flash[:message] = "You have signed up to present your hack"
    redirect_to :back
  end

  def leave_queue
    @hack.hackday.leave_queue(@hack)
    flash[:message] = "You will no longer presenting your hack."
    redirect_to :back
  end

  private

  def get_hack
    @hack = Hack.find(params[:id])
  end

  def check_signed_in
    unless current_user
      flash[:error] = "You need to be signed in first!"
      return redirect_to :back
    end
  end

  def check_permission
    unless @hack.has_contributor?(current_user)
      flash[:error] = "You don't have permission to perform this action."
      return redirect_to @hack.hackday
    end
  end

end
