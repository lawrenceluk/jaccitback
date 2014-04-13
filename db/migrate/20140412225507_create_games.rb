class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
    	t.integer :p1score
    	t.integer :p2score
    	t.integer :highscore

      t.timestamps
    end
  end
end
