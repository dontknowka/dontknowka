Hanami::Model.migration do
  change do
    create_table :competitions do
      primary_key :id
      foreign_key :assignment_id, :assignments, on_delete: :cascade, null: false

      column :name, String, null: false
      column :score, Integer, null: false

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end
