class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.integer :user_id
      t.string :username
      t.string :status
      t.integer :requests
      t.integer :plays
      t.integer :points
      t.integer :highscore

      t.timestamps
    end
  end
end
