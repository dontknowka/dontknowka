Hanami::Model.migration do
  change do
    create_table :homeworks do
      primary_key :id

      column :number, Integer
      column :kind, String, size: 1
      unique [:number, :kind]

      column :prepare_deadline, DateTime, null: false
      column :approve_deadline, DateTime, null: false

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end
