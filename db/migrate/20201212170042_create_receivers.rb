# frozen_string_literal: true

class CreateReceivers < ActiveRecord::Migration[6.0]
  def change
    create_table :receivers do |t|
      t.string :name
      t.string :telegram_chat_id
      # rubocop:disable Rails/ThreeStateBooleanColumn
      t.boolean :include_wbs
      # rubocop:enable Rails/ThreeStateBooleanColumn
      t.integer :minimum_rooms_number
      t.integer :maximum_rooms_number

      t.timestamps
    end
  end
end
