class CreateFavUrls < ActiveRecord::Migration
  def self.up
    create_table :fav_urls do |t|
      t.string :name
      t.string :url
      t.string :description
    end
    default_fav_url=FavUrl.new()
    default_fav_url.name="SunriseTelecom"
    default_fav_url.url="www.sunrisetelecom.com"
    default_fav_url.description="We develop test and measurement solutions for telecom, cable, and wireless networks that ensure network performance, speed deployment, and reduce the cost of network operations."
    default_fav_url.id=1;
    default_fav_url.save()
  end

  def self.down
    FavUrl.delete_all
    drop_table :fav_urls
  end
end
