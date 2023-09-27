# frozen_string_literal: true

class AddIndexToReadByUsersFromJournals < ActiveRecord::Migration[6.1]
  def change
    add_index :journals, :read_by_users
  end
end
