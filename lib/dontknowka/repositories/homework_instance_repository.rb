class HomeworkInstanceRepository < Hanami::Repository
  associations do
    belongs_to :homework
    has_one :homework_set
  end

  def by_name(name)
    aggregate(:homework)
      .where(name: name)
      .map_to(HomeworkInstance)
      .one
  end

  def all_values
    homework_instances
      .read("SELECT * FROM homework_instances")
      .map
      .to_a
  end
end
