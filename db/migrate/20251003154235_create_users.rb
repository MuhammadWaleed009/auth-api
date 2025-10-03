class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :user_id, null: false
      t.string :password_digest, null: false
      t.string :nickname
      t.string :comment
      t.timestamps
    end

    add_index :users, :user_id, unique: true
  end
end
