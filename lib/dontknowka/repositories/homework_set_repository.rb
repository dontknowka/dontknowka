class HomeworkSetRepository < Hanami::Repository
  associations do
    belongs_to :homework_instance
    belongs_to :homeworks, through: :homework_instances
  end

  def all_set_names
    homework_sets.read("SELECT DISTINCT homework_sets.name, homeworks.prepare_deadline FROM homeworks INNER JOIN homework_instances ON (homeworks.id = homework_instances.homework_id) INNER JOIN homework_sets ON (homework_instances.id = homework_sets.homework_instance_id) ORDER BY homeworks.prepare_deadline")
      .map_to(HomeworkSet)
      .to_a
      .map{|x| x.name}
      .uniq
  end

  def get_instances(name)
    aggregate(:homework_instance)
      .where(name: name)
      .map_to(HomeworkSet)
      .to_a
  end
end
