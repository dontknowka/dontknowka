class HomeworkInstanceRepository < Hanami::Repository
  associations do
    belongs_to :homework
    has_one :homework_set
    has_many :assignments
    has_many :students, through: :assignments
  end

  def by_name(name)
    aggregate(:homework)
      .where(name: name)
      .map_to(HomeworkInstance)
      .one
  end
end
