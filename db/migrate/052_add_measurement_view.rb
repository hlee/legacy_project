class AddMeasurementView < ActiveRecord::Migration
  def self.up
    execute "create or replace view measurement_view as 
    select measures.measure_name as measure, sites.name as site, channels.channel_name as channel,dt,value 
    from ((
      measurements left join channels on channels.id=measurements.channel_id) 
      left join measures on measures.id=measurements.measure_id) 
      left join sites on sites.id=measurements.site_id"
  end

  def self.down
    execute "drop view measurement_view"
  end
end
