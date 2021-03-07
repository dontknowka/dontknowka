Hanami::Model.migration do
  change do
    create_table :students do
      column :id, Integer, null: false, unique: true, primary_key: true

      column :login, String, null: false, unique: true, size: 80
      column :first_name, String, null: false, size: 30
      column :last_name, String, null: false, size: 30
      column :email, String, null: false, unique: true, size: 50
      column :avatar, String
      column :group, String, null: false, size: 10
      column :late_days, Integer, default: 14

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end
