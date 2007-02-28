module Earth
  class CachedSize < ActiveRecord::Base
    belongs_to :directory

    def size
      Size.new(bytes, blocks, count)
    end
    
    def increment(file_or_cached_size)
      self.bytes += file_or_cached_size.bytes
      self.blocks += file_or_cached_size.blocks
      if file_or_cached_size.respond_to?("count")
        self.count += file_or_cached_size.count
      else
        self.count += 1
      end
    end

    def update
      # do not update; updating of cached_size is done with a bulk
      # update from directory's after_update callback.
    end
  end
end
