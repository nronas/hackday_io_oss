class UpdateHacks < ActiveRecord::Migration
  def change
    add_column :hacks, :win, :boolean
    add_column :hacks, :trophy, :string
    add_column :hacks, :tags, :string
    add_column :hacks, :video, :string
  end
end
