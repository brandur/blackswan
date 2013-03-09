Sequel.migration do
  up do
    create_table(:events) do
      primary_key :id
      String   :slug,        null: false
      String   :content,     null: false
      DateTime :occurred_at, null: false
    end

    run "CREATE EXTENSION IF NOT EXISTS hstore"
    run "ALTER TABLE events ADD COLUMN metadata hstore"
  end

  down do
    drop_table(:events)
    run "DROP EXTENSION hstore"
  end
end
