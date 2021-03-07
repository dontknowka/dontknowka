Hanami::Model.migration do
  change do
    create_table :assignments do
      primary_key :id
      foreign_key :student_id, :students, on_delete: :cascade, null: false
      foreign_key :homework_instance_id, :homework_instances, on_delete: :cascade, null: false

      column :status, String, size: 20, default: 'open', null: false
      column :prepare_deadline, DateTime, null: false
      column :approve_deadline, DateTime, null: false
      column :url, String
      column :repo, String
      column :check_runs, Integer, default: 0
      column :last_update, DateTime

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end
