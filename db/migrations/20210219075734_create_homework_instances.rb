Hanami::Model.migration do
  change do
    create_table :homework_instances do
      primary_key :id
      foreign_key :homework_id, :homeworks, on_delete: :cascade, null: false

      column :name, String, null: false, unique: true
      column :worth, Integer, null: false
      column :classroom_url, String, null: false, unique: true

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end
