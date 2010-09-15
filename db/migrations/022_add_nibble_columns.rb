Class.new Sequel::Migration do
  def up
    return if FXC.db[:users].columns.include?(:balance)

    alter_table :users do
      add_column :balance, BigDecimal, :default => '0.00', :null => false
    end

    return if FXC.db[:users].columns.include?(:nibble_rate)

    alter_table :users do
      add_column :nibble_rate, BigDecimal, :default => nil
    end
  end

  def down
    return unless FXC.db[:users].columns.include?(:balance)

    alter_table :users do
      drop_column :balance
    end

    return unless FXC.db[:users].columns.include?(:nibble_rate)

    alter_table :users do
      drop_column :nibble_rate
    end
  end
end
