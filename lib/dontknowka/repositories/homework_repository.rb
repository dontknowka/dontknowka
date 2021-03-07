class HomeworkRepository < Hanami::Repository
  associations do
    has_many :homework_instances
    has_many :homework_sets, through: :homework_instances
  end
end
