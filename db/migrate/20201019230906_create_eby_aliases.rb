class CreateEbyAliases < ActiveRecord::Migration[6.0]
  def change
    create_table :eby_aliases do |t|
      t.references :eby_def, null: false, foreign_key: true, type: :integer
      t.string :alias

      t.timestamps
    end
  end
end
