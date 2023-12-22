# frozen_string_literal: true

class AddReadByUsersToMessages < ActiveRecord::Migration[6.1]
  def change
    add_column :messages, :read_by_users, :text, default: "{}", null: false
  end
end