# This class provide methods for managing any metadata
#
# Author:: Mohammad Bamogaddam, Ming

class Metadata < EarthPlugin
  
  
  # the +save_file_metadata+ save metadata for a given file
  # if there is already metdata for this file it will be deleted and the new ones will be saved
  # === Parameters: TODO
  # TODO we may create a new method to add metadata to the existing ones
  # TODO we may send the plug-in reference which should be used to extract metadata, currently use rsp_metadata
  def self.save_file_metadata(file_id)
    
    #delete any metadata for this file
    self.delete_file_metadata(file_id)
    
    rspmeta = RspMetadata.new
    # find the object file for the passed file_id
    begin
      file = Earth::File.find(file_id)
      # extract metadata for the given file using another plug-in
      # TODO the used class to extract metadata could be changed to a passed parameter. so it will be more generic
      metadata = rspmeta.file_metadata(file)
    rescue ActiveRecord::RecordNotFound
      STDERR.puts "File #{file_id} not found"
      return
    end
    
    
    
    # :metadata_key_value_pairs
    i=0
    while i < metadata.size do
      
      Earth::MetadataKeyValuePair.create(:file_id => file_id,  :key => metadata.keys[i],  :value => metadata.values[i])
      i+=1
    end
  end
  
  # the +delete_metadata+ method deletes any metadata associated with the passed file_id
  # === Parameters: TODO 
  def self.delete_file_metadata(file_id)
    key_value_records = Earth::MetadataKeyValuePair.find(:all, :conditions => ["file_id = ?", file_id])
    for i in 0..key_value_records.size do
      Earth::MetadataKeyValuePair.delete(key_value_records[i])
    end
  end
  
  # deletes all files_metadata for all files under a directory and its subdirectories
  # ===Parameters: TODO
  def self.delete_all_files_metadata_under_dir(dir)
    
    if dir.direct_children.size == 0
      delete_list_files_metadata(dir.files)
      return
    end
    
    children = dir.direct_children
    
    for i in 0..children.size-1 do
      delete_all_files_metadata_under_dir(children[i])
    end
  end
  
  
  # the +delete_metadata+ method deletes any metadata associated with all files
  # === Parameters: TODO 
  def self.delete_list_files_metadata(files)
    for i in 0..files.size do
      self.delete_file_metadata(files[i])
    end
  end
  
end
