class FXC::Voicemail < Sequel::Model(FXC.db[:voicemail_msgs])
  @scaffold_human_name = 'Voicemail'
  @scaffold_column_types = {
    :cid_name => :string,
    :cid_number => :string,
    :domain => :string,
    :file_path => :string,
    :flags => :string,
    :in_folder => :string,
    :read_flags => :string,
    :username => :string,
    :uuid => :string,
  }

  def timestamp
    Time.at(created_epoch).utc.strftime("%m/%d/%Y %H:%M")
  end
end
