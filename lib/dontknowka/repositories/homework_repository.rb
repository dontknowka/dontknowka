class HomeworkRepository < Hanami::Repository
  associations do
    has_many :homework_instances
    has_many :homework_sets, through: :homework_instances
    has_many :assignments, through: :homework_instances
  end

  def with_assignments(id)
    homeworks
      .read("SELECT homework_instances.name AS homework_instance_name, homework_instances.worth AS homework_instance_worth, assignments.id AS assignment_id, assignments.status AS assignment_status, assignments.url AS assignment_url, students.login AS student_login, students.first_name AS student_first_name, students.last_name AS student_last_name, COUNT (DISTINCT reviews.id) AS reviews, COUNT(check_runs.id) AS check_runs FROM homeworks INNER JOIN homework_instances ON (homeworks.id = homework_instances.homework_id AND homeworks.id = #{id}) INNER JOIN assignments ON (homework_instances.id = assignments.homework_instance_id) INNER JOIN students ON (assignments.student_id = students.id) LEFT JOIN reviews ON (assignments.id = reviews.assignment_id) LEFT JOIN check_runs ON (assignments.id = check_runs.id) GROUP BY homework_instances.name, homework_instances.worth, assignments.id, assignments.status, assignments.url, students.login, students.first_name, students.last_name ORDER BY homework_instances.name, students.last_name, students.first_name")
      .map
      .to_a
  end
end
