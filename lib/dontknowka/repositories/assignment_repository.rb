class AssignmentRepository < Hanami::Repository
  associations do
    belongs_to :homework_instance
    belongs_to :homework, through: :homework_instances
    belongs_to :homework_set, through: :homework_instances
    belongs_to :student
  end

  def by_student(student)
    aggregate(:homework_instance)
      .where(student_id: student.id)
      .map_to(Assignment)
      .to_a
  end

  def by_student_id(id)
    aggregate(:homework_instance)
      .where(student_id: id)
      .map_to(Assignment)
      .to_a
  end

  def by_instance(student_id, id)
    assignments
      .where(student_id: student_id, homework_instance_id: id)
      .map_to(Assignment)
      .to_a
  end

  def by_repo(repo_name)
    assignments
      .where { repo.ilike("%#{repo_name}") }
      .map_to(Assignment)
      .to_a
  end

  def with_sets(student)
    assignments.read("SELECT homeworks.kind AS homework_kind, homeworks.number AS homework_number, homework_instances.name AS homework_instance_name, homework_instances.classroom_url, homework_instances.worth, homework_sets.name AS homework_set_name, assignments.id, assignments.status, assignments.url, assignments.prepare_deadline, assignments.approve_deadline FROM homeworks INNER JOIN homework_instances ON (homeworks.id = homework_instances.homework_id) INNER JOIN homework_sets ON (homework_instances.id = homework_sets.homework_instance_id) INNER JOIN assignments ON (homework_instances.id = assignments.homework_instance_id AND assignments.student_id = #{student.id})")
      .map
      .to_a
  end
end
