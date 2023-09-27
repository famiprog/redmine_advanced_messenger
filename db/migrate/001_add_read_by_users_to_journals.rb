# frozen_string_literal: true

class AddReadByUsersToJournals < ActiveRecord::Migration[6.1]
  def change
    add_column :journals, :read_by_users, :text, default: "{}", null: false
  end
end
