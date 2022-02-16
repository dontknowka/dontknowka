Hanami::Model.migration do
  change do
    create_table :check_runs do
      column :id, Integer, null: false, unique: true, primary_key: true
      foreign_key :assignment_id, :assignments, on_delete: :cascade, null: false

      column :url, String
      column :completed_at, DateTime, null: false
      column :pull, Integer

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end
