class LinksController < ApplicationController

  caches_page :index

  def index  
    @link = Link.new
    @recent_links = Link.find(:all,:limit=>5,:order=>"updated_at DESC")
    @visited_links = Link.find(:all,:limit=>5,:order=>"visits_count DESC")
    render :action => 'index'
  end
  
  def create
    @website_url = params.include?(:website_url) ? params[:website_url] : params[:link][:website_url]
    @link = Link.find_or_create_by_url(@website_url)
    unless @link.is_a?(String)
      @link.ip_address = request.remote_ip if @link.new_record?    
      expire_page :action => :index
      if @link.save
        calculate_links # application controller, refactor soon
        render :action => :show
      else
        # flash[:warning] = 'There was an issue trying to create your tinyThom.as URL.'
        Prowler.notify "Invalid", @website_url.to_s, Prowler::Priority::NORMAL unless @website_url.to_s.strip == ""
        redirect_to :action => :invalid
      end
    else
      render :action => :expired#, :website_url=>@website_url 
    end
  end
  
  # def expired
  #   @website_url = params[:website_url]
  # end

  def redirect
    @link = Link.find_by_token( params[:token] )
    unless @link
      @link = Link.find_or_create_by_bill( params[:token] )
      if @link and @link.new_record?
        @link.ip_address = request.remote_ip
        if @link.save
          calculate_links
        else
          redirect_to :action => 'invalid'
          return
        end
      end
    end
    params[:site] = "thomas" unless (params[:site] == "oc" or params[:site] == "gt")
    unless @link.nil?
      @link.add_visit(request, params[:site])
      if params[:site] == "oc" and oc_link = @link.opencongress_link
        redirect_to oc_link, { :status => 301 }        
      elsif params[:site] == "gt" and gt_link = @link.govtrack_link
        redirect_to gt_link, { :status => 301 }
      else
        redirect_to @link.thomas_permalink, { :status => 301 }
      end
    else
      redirect_to :action => 'invalid'
    end
  end
  
  def test
    logger.debug params[:content]
  end
  
  private
  
  
end
