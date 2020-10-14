class CreateApartments < ActiveRecord::Migration[6.0]
  def change
    create_table :apartments do |t|
      t.string :external_id, null: false
      t.jsonb :properties, null: false, default: {}

      t.timestamps
    end
  end
end
