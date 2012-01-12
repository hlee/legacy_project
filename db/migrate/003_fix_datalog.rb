class FixDatalog < ActiveRecord::Migration
  def self.up
     add_column "datalogs", "image",:binary,{:limit => 2.kilobytes}
     add_column "datalogs", "min_image",:binary,{:limit => 2.kilobytes}
     add_column "datalogs", "max_image",:binary,{:limit => 2.kilobytes}
  end

  def self.down
     remove_column "datalogs","image"
     remove_column "datalogs","min_image"
     remove_column "datalogs","max_image"
  end
end
