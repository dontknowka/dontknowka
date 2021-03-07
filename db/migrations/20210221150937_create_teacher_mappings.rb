Hanami::Model.migration do
  change do
    create_table :teacher_mappings do
      primary_key :id
      foreign_key :teacher_id, :teachers, on_delete: :cascade, null: false
      foreign_key :homework_instance_id, :homework_instances, on_delete: :cascade, null: false

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end
