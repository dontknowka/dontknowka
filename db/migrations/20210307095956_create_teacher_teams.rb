Hanami::Model.migration do
  change do
    create_table :teacher_teams do
      column :id, Integer, null: false, unique: true, primary_key: true

      column :slug, String, null: false, unique: true, size: 80
      column :name, String, null: false, size: 80
      column :avatar, String

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end
