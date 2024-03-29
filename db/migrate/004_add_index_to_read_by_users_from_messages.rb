# frozen_string_literal: true

class AddIndexToReadByUsersFromMessages < ActiveRecord::Migration[6.1]
  def up
    case connection.adapter_name
    when 'PostgreSQL'
      enable_extension("pg_trgm");
      add_index(:messages, :read_by_users, using: 'gin', opclass: :gin_trgm_ops)
    end
  end

  def down
    case connection.adapter_name
    when 'PostgreSQL'
      remove_index(:messages, :read_by_users);
      disable_extension("pg_trgm");
    end
  end
end
