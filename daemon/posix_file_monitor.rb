class PosixFileMonitor < FileMonitor
  def initialize(directory, observer)
    super(observer)
    dir = directory_added(File.expand_path(directory))
    @snapshots = {File.expand_path(directory) => Snapshot.new(self, dir)}
  end
  
  def remove_directory(path)
    directory = @snapshots[path].directory

    @snapshots[path].subdirectory_names.each {|x| remove_directory(File.join(path, x))}
    @snapshots[path].file_names.each {|x| file_removed(directory, x)}
    directory_removed(directory)
    @snapshots.delete(path)
  end
  
  def add_directory(path)
    dir = directory_added(path)
    snapshot = Snapshot.new(self, dir)
    @snapshots[path] = snapshot
    old_snapshot = snapshot.deep_copy
    snapshot.update

    Difference.added_files(old_snapshot, snapshot).each {|x| file_added(dir, x, snapshot.stat(x))}
    Difference.added_directories(old_snapshot, snapshot).each {|x| add_directory(File.join(path, x))}
  end
  
  def update
    @snapshots.each do |path, snapshot|
      directory = snapshot.directory
      old_snapshot = snapshot.deep_copy
      snapshot.update

      Difference.changed_files(old_snapshot, snapshot).each {|x| file_changed(directory, x, snapshot.stat(x))}
    
      Difference.added_directories(old_snapshot, snapshot).each {|d| add_directory(File.join(path, d))}
      Difference.added_files(old_snapshot, snapshot).each {|x| file_added(directory, x, snapshot.stat(x))}
      Difference.removed_files(old_snapshot, snapshot).each {|x| file_removed(directory, x)}
      Difference.removed_directories(old_snapshot, snapshot).each {|d| remove_directory(File.join(path, d))}
    end
  end
end
