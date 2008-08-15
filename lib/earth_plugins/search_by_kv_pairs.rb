
# Author::Qing Yang
 

class SearchByKVPairs < EarthPlugin

  # TODO: add method comments
  # The search_by(key,value) method is writen by QING Yang
  
  # Both key and value are from the input of view, which are entered by users.
  # If key and value are not blank, we find out all the files which include the key and value pairs.
  # It means if we assume the key is "job" and the value is "A",then the method return all the files 
  # which have the key and value pairs like ("job","A").
  
  
   
   def self.search_by(key,value)
      result_set_files=Array.new   
      rsp_name=value
      rsp_name="*" if rsp_name.blank?
         
      rsp_key=key
      rsp_key="*" if rsp_key.blank?
      
      if rsp_name!="*"&& rsp_key!="*"
        
        mkvps=Earth::MetadataKeyValuePair.find(:all,:conditions=>
                                                  ["key LIKE ? and value LIKE ?",key,"%"+value+"%"])
        mkvps.each do |m|
          id=m.file_id
          file=Earth::File.find(id)   
          result_set_files.push(file)
        end
      end
       
                                                                
       return result_set_files
        
   end


end
