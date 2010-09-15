Class.new Sequel::Migration do
  def up
    return if FXC.db[:users].columns.include?(:timezone)

    alter_table :users do
      add_column :timezone, String
    end
  end

  def down
    return unless FXC.db[:users].columns.include?(:timezone)

    alter_table :users do
      drop_column :timezone
    end
  end
end
