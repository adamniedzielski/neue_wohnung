# frozen_string_literal: true

class AddNotNullForReceiver < ActiveRecord::Migration[6.1]
  def change
    change_column_null(:receivers, :name, false)
    change_column_null(:receivers, :telegram_chat_id, false)
    change_column_null(:receivers, :include_wbs, false)
    change_column_null(:receivers, :minimum_rooms_number, false)
    change_column_null(:receivers, :maximum_rooms_number, false)
  end
end
