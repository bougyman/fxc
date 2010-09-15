Class.new Sequel::Migration do
  def up
    return if FXC.db[:users].columns.include?(:email)

    alter_table :users do
      add_column :email, String
    end
  end

  def down
    return unless FXC.db[:users].columns.include?(:email)

    alter_table :users do
      drop_column :email
    end
  end
end
