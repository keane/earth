# This class provide methods for managing RSP metadata
#
# Author:: Mohammad Bamogaddam
 
 
class RspMetadata < EarthPlugin
  
  # constant variable used to save rsp naming convention
  RSP_KEYS = ["job","sequence","shot"]
  
  # the +rsp_keys+ method returns array of rsp keys
  def self.rsp_keys
    RSP_KEYS
  end
  
  
  # the +file_metadata+ method returns hash of keys and values
  # representing the passed file metadata
  # === Parameters
  # * _file_ = a file object, represent a record in files table
  #
  # === Example
  # r = RspMetadata.new
  # f1 = Earth::File.find(:first, :conditions => ["name = ?", "pic_003.jpg"])
  # r.file_metadata(f1) => {"job" => "", "sequence" => "", "shot" => ""}
  #
  def file_metadata(file)
    # Find the parent directory for the given file
    # TODO: catch any exception (record not found, etc)
    directory = Earth::Directory.find(file.directory_id)
    # save the path
    path = directory.path
    # parse the path, look for keys and save metadata
    metadata = parse_path(path)
    return metadata
  end
   
  
  
  

   
   
  private
  
  # the +parse_path+ parses a given path looking for keys
  # returns hash of keys and values
  # === Parameters
  # * _path_ = String represent some path (e.g. "rsp/job_001/sequence_003/shot_104")
  # === Example
  # parse_path("rsp/job_001/sequence_003/shot_104") => {"job" => "_001", "sequence" => "_003", "shot" => "_104"}
  #
  def parse_path(path)
    metadata = {}
    # split the path into tokens
    tokens = path.split('/')
    # loop all over the tokens looking for keys (or something similar to keys)
    tokens.each do |token|
      # find the index of the key (alike)
      index = match_one_of(RSP_KEYS, token)
      if index >= 0
        # extract the value
        value = extract_value(RSP_KEYS[index], token)
        # save key, value pairs
        metadata[RSP_KEYS[index]] = value
      end
    end
    metadata
  end
  
  # the +match_one_of+ method search in array of keys and comparing each key with a string (_test_)
  # if one of the keys is found in _test_ => return its index
  # if not => return -1
  # === Parameters
  # * _keys_ = Array of Strings
  # * _test_ = String
  # === Example:
  # keys = ["job","sequence","shot"]
  # test = "job_LOR"
  # match_one_of(keys, test) => 0 (index of "job")
  def match_one_of(keys, test)
    keys.each do |key|
      if test =~ Regexp.new(key)
        return keys.index(key)
      end
    end
    return -1
  end
  
  # the +extract_value+ method extracts a key value from a String (_test_)
  # returns a String represent the value of the _key_ in _test_
  # === Pararmeters
  # * _key_ = String (e.g. "job")
  # * _test = String (e.g. "job_LOR")
  # === Example
  # extract_value("job", "job_LOR") => "_LOR"
  def extract_value(key, test)
    test.sub(Regexp.new(key), "")
  end
  
end
