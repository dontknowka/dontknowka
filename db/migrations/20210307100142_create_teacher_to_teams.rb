Hanami::Model.migration do
  change do
    create_table :teacher_to_teams do
      primary_key :id
      foreign_key :teacher_id, :teachers, on_delete: :cascade, null: false
      foreign_key :teacher_team_id, :teacher_teams, on_delete: :cascade, null: false

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end
