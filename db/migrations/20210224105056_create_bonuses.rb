Hanami::Model.migration do
  change do
    create_table :bonuses do
      primary_key :id
      foreign_key :student_id, :students, on_delete: :cascade, null: false

      column :worth, Integer, null: false
      column :why, String

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end
