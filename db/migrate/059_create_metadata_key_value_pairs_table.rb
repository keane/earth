# Copyright (C) 2007 Rising Sun Pictures and Matthew Landauer
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

class CreateMetadataKeyValuePairsTable < ActiveRecord::Migration
  def self.up
      create_table :metadata_key_value_pairs do |t|
      t.column :key, :string, :null => false
      t.column :value, :string, :null => false
      t.column :file_id, :integer
    end
    add_foreign_key :metadata_key_value_pairs, :file_id, :files, :id, { :name => "files_metadata_key_value_pairs_id_fk" }
  end
  
  def self.down
    remove_foreign_key :metadata_key_value_pairs, :files_metadata_key_value_pairs_id_fk
    drop_table :metadata_key_value_pairs
  end  
end
