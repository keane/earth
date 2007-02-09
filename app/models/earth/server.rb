require 'socket'

module Earth
  class Server < ActiveRecord::Base
    has_many :directories, :dependent => :destroy, :order => :lft
  
    def Server.this_server
      Server.find_or_create_by_name(ENV["EARTH_HOSTNAME"] || this_hostname)
    end
    
    def Server.this_hostname
      Socket.gethostname
    end
    
    def size
      Earth::Directory.roots_for_server(self).map{|d| d.size}.sum      
    end
    
    def recursive_file_count
      Earth::Directory.roots_for_server(self).map{|d| d.recursive_file_count}.sum
    end
    
    def has_files?
      recursive_file_count > 0
    end
    
    def heartbeat
      self.heartbeat_time = Time.now
      save!
    end
    
    def daemon_alive?
      if heartbeat_time.nil? or daemon_version.nil?
        false
      else
        (heartbeat_time + heartbeat_interval) >= Time::now
      end
    end
    
  end
end
