Hanami::Model.migration do
  change do
    create_table :homework_sets do
      primary_key :id
      foreign_key :homework_instance_id, :homework_instances, on_delete: :cascade, null: false

      column :name, String, null: false
      column :variant_id, Integer, null: false

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end
