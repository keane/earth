require 'csv'
require 'pp'

class BrowserController < ApplicationController
  def index
    redirect_to :action => 'show'
  end

  def flat
    @server = Earth::Server.find_by_name(params[:server]) if params[:server]
    @directory = @server.directories.find_by_path(params[:path].to_s) if @server && params[:path]

    @show_hidden = params[:show_hidden]

    @any_empty = false
    @any_hidden = true
    
    @page_size = 25
    @current_page = (params[:page] || 1).to_i

    joins = "JOIN directories ON files.directory_id = directories.id"
    order = "files.bytes desc"
    include_attributes = [ "name", "directory_id", "modified", "bytes", "uid" ]
    select = include_attributes.map {|attr| "files.#{attr} as #{attr}" }.join(", ")

    if @directory
      conditions = [ 
        "directories.server_id = ? " + \
        " AND directories.lft >= ? " + \
        " AND directories.lft <= ?", 
        @server.id, 
        @directory.lft, 
        @directory.rgt 
      ]
    elsif @server
      conditions = [ 
        "directories.server_id = ?", 
        @server.id 
      ]
    else
      conditions = nil
    end

    if not @show_hidden
      if conditions
        conditions[0] = "(not files.name like '.%') and " + conditions[0]
      else
        conditions = "not files.name like '.%'"
      end
    end

    Earth::File.with_filter(params) do
      file_count = Earth::File.count(:joins => joins, 
                                     :conditions => conditions)
      @page_count = (file_count + @page_size - 1) / @page_size
      

      @files = Earth::File.find(:all, 
                                :select => select,
                                :joins => joins,
                                :conditions => conditions,
                                :order => order,
                                :offset => ((@current_page - 1) * @page_size),
                                :limit => @page_size)
    end
  end

  def show
    @server = Earth::Server.find_by_name(params[:server]) if params[:server]
    @directory = @server.directories.find_by_path(params[:path].to_s) if @server && params[:path]
    # Filter parameters
    @show_empty = params[:show_empty]
    @show_hidden = params[:show_hidden]

    Earth::File.with_filter(params) do
      # if at the root
      if @server.nil?
        servers = Earth::Server.find(:all)
      # if at the root of a server
      elsif @server && @directory.nil?
        directories = Earth::Directory.roots_for_server(@server)
      # if in a directory on a server
      elsif @server && @directory
        directories = @directory.children
        # Scoping appears to not work on associations so doing the find explicitly
        @files = Earth::File.find(:all, :conditions => ['directory_id = ?', @directory.id])
      end
      
      # Filter out servers and directories that have no files, query sizes
      if servers
        @any_empty = false
        @servers_and_bytes = servers.map do |s|
          size = s.size
          @any_empty = true if size.count == 0
          if @show_empty || size.count > 0
            [s, size.bytes]
          end
        end
        # Remove any nil entries resulting from empty servers
        @servers_and_bytes.delete_if { |entry| entry.nil? }
      elsif directories
        # Instead of filtering out empty directories ahead of time,
        # which requires one additional query per directory, get
        # directory size and file count for each directory in one go
        # and filter out empty directories after the fact
        any_empty_directories = false
        any_hidden_directories = false
        @directories_and_bytes = directories.map do |d| 
          size = d.size
          any_empty_directories = true if size.count == 0
          any_hidden_directories = true if /^\./ =~ d.name
          if (@show_empty || size.count > 0) && (@show_hidden || /^[^.]/ =~ d.name)
            [d, size.bytes]
          end
        end
        @any_empty = any_empty_directories || (@files.any? { |file| file.bytes == 0 } if @files)
        @any_hidden = any_hidden_directories || (@files.any? { |file| /^\./ =~ file.name } if @files)

        # Remove any nil entries resulting from empty directories
        @directories_and_bytes.delete_if { |entry| entry.nil? }

        @files = @files.select { |file| /^[^.]/ =~ file.name } if @files and not @show_hidden
      end
    end
    
    respond_to do |wants|
      wants.html
      wants.xml {render :action => "show.rxml", :layout => false}
      wants.csv do
        @csv_report = StringIO.new
        CSV::Writer.generate(@csv_report, ',') do |csv|
          csv << ['Directory', 'Size (bytes)']
          for directory, size in @directories_and_bytes
            csv << [directory.name, size]
          end
        end
        
        @csv_report.rewind
        send_data(@csv_report.read, :type => 'text/csv; charset=iso-8859-1; header=present', :filename => 'earth_report.csv', :disposition => 'downloaded')
      end

      logger.debug("end of controller")
    end
  end
  
  def auto_complete_for_filter_user
    if User.ldap_configured?
      @users = User.find_matching(params[:filter_user])
      render :inline => '<%= content_tag("ul", @users.map { |user| content_tag("li", h(user.name)) })%>'
    end
  end
end
