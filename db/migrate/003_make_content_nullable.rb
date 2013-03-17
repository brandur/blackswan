Sequel.migration do
  up do
    run "ALTER TABLE events ALTER COLUMN content DROP NOT NULL"
  end

  down do
    run "ALTER TABLE events ALTER COLUMN content SET NOT NULL"
  end
end
