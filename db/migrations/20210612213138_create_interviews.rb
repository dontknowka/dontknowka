Hanami::Model.migration do
  change do
    create_table :interviews do
      column :id, Integer, null: false, unique: true, primary_key: true
      foreign_key :assignment_id, :assignments, on_delete: :cascade, null: false
      foreign_key :teacher_id, :teachers, on_delete: :cascade, null: false

      column :submitted_at, DateTime, null: false
      column :malus, Integer, null: false
      column :url, String

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end
