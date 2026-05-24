class CreateEbyDefs < ActiveRecord::Migration[4.2]
  def change
    create_table :eby_defs do |t|
      t.string :defhead
      t.text :deftext
      t.integer :assignedto
      t.string :status
      t.integer :proof_round_passed
      t.string :arabic
      t.string :greek
      t.string :russian
      t.string :extra
      t.text :footnotes

      t.timestamps
    end
  end
end
