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

  def get_variants(name)
    homework_sets.read("SELECT homeworks.id AS homework_id, homework_instances.id AS homework_instance_id, homework_instances.name AS homework_instance_name, homework_sets.name AS homework_set_name, homework_sets.variant_id, homeworks.prepare_deadline, homeworks.approve_deadline FROM homeworks INNER JOIN homework_instances ON (homeworks.id = homework_instances.homework_id) INNER JOIN homework_sets ON (homework_instances.id = homework_sets.homework_instance_id AND homework_sets.name = '#{name}') ORDER BY homework_sets.name, homework_sets.variant_id, homeworks.prepare_deadline")
      .map
      .to_a
      .group_by {|x| x[:variant_id]}
      .values
  end
end
