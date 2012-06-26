class CreateEbyUsers < ActiveRecord::Migration
  def change
    create_table :eby_users do |t|
      t.string :login
      t.string :password
      t.string :fullname
      t.string :email
      t.integer :max_proof_level
      t.boolean :role_partitioner
      t.boolean :role_typist
      t.boolean :role_fixer
      t.boolean :role_publisher
      t.boolean :role_proofer
      t.boolean :does_russian
      t.boolean :does_arabic
      t.boolean :does_greek
      t.boolean :does_extra

      t.timestamps
    end
  end
end
