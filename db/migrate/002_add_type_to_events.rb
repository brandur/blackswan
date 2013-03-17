Sequel.migration do
  up do
    add_column :events, :type, String
    run "UPDATE events SET type = 'twitter'"
  end

  down do
    drop_column :events, :type
  end
end
