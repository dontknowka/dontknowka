class AssignmentRepository < Hanami::Repository
  associations do
    belongs_to :homework_instance
    belongs_to :homework, through: :homework_instances
    belongs_to :homework_set, through: :homework_instances
    belongs_to :student
    has_many :reviews
    has_many :check_runs
    has_one :interview
    has_many :competitions
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

  def all_by_instance(id)
    assignments
      .where(homework_instance_id: id)
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
    assignments.read("SELECT homeworks.kind AS homework_kind, homeworks.number AS homework_number, homework_instances.name AS homework_instance_name, homework_instances.classroom_url, homework_instances.worth, homework_sets.name AS homework_set_name, assignments.id AS assignment_id, assignments.status, assignments.url, assignments.prepare_deadline, assignments.approve_deadline FROM homeworks INNER JOIN homework_instances ON (homeworks.id = homework_instances.homework_id) INNER JOIN homework_sets ON (homework_instances.id = homework_sets.homework_instance_id) INNER JOIN assignments ON (homework_instances.id = assignments.homework_instance_id AND assignments.student_id = #{student.id})")
      .map
      .to_a
  end

  def with_reviews(student)
    aggregate(:homework_instance, :reviews, :check_runs, :interview, :competitions)
      .where(student_id: student.id)
      .map_to(Assignment)
      .to_a
  end

  def awaiting_reviews(instances)
    if instances.empty?
      []
    else
      assignments.read("SELECT assignments.id, assignments.status, homework_instances.name AS name, approve_deadline, assignments.repo AS repo, assignments.url AS repo_url, students.login AS login FROM homework_instances INNER JOIN assignments ON (homework_instances.id = assignments.homework_instance_id AND homework_instances.id IN (#{instances.join(',')})) INNER JOIN students ON (assignments.student_id = students.id) LEFT JOIN reviews ON (assignments.id = reviews.assignment_id) WHERE assignments.status = 'ready' AND reviews.assignment_id IS NULL ORDER BY approve_deadline, assignments.last_update")
        .map
        .to_a
    end
  end

  def updated_after_review(instances)
    if instances.empty?
      []
    else
      assignments.read("SELECT assignments.id, assignments.status, homework_instances.name AS name, approve_deadline, assignments.repo AS repo, assignments.url AS repo_url, students.login AS login, MAX(check_runs.completed_at) AS updated_at FROM homework_instances INNER JOIN assignments ON (homework_instances.id = assignments.homework_instance_id AND homework_instances.id IN (#{instances.join(',')})) INNER JOIN students ON (assignments.student_id = students.id) INNER JOIN reviews ON (assignments.id = reviews.assignment_id) INNER JOIN check_runs ON (assignments.id = check_runs.assignment_id) WHERE assignments.status = 'ready' GROUP BY assignments.id, assignments.status, homework_instances.name, approve_deadline, assignments.repo, assignments.url, students.login HAVING MAX(reviews.submitted_at) < MAX(check_runs.completed_at) ORDER BY MAX(check_runs.completed_at)")
        .map
        .to_a
    end
  end

  def expired(instances, deadline)
    if instances.empty?
      []
    else
      assignments.read("SELECT assignments.id, assignments.status, homework_instances.name AS name, approve_deadline, assignments.repo AS repo, assignments.url AS repo_url, students.login AS login FROM homework_instances INNER JOIN assignments ON (homework_instances.id = assignments.homework_instance_id AND homework_instances.id IN (#{instances.join(',')})) INNER JOIN students ON (assignments.student_id = students.id) WHERE assignments.status NOT IN ('open', 'approved', 'failed') AND assignments.approve_deadline < '#{deadline}' ORDER BY assignments.created_at, approve_deadline")
        .map
        .to_a
    end
  end

  def failed(instances)
    if instances.empty?
      []
    else
      assignments.read("SELECT assignments.id, assignments.status, homework_instances.name AS name, assignments.repo AS repo, assignments.url AS repo_url, students.login AS login FROM homework_instances INNER JOIN assignments ON (homework_instances.id = assignments.homework_instance_id AND homework_instances.id IN (#{instances.join(',')})) INNER JOIN students ON (assignments.student_id = students.id) WHERE assignments.status = 'failed'")
        .map
        .to_a
    end
  end

  def not_approved(instances)
    if instances.empty?
      []
    else
      assignments.read("SELECT assignments.id, assignments.status AS status, homework_instances.name AS name, prepare_deadline, approve_deadline, assignments.repo AS repo, assignments.url AS repo_url, students.login AS login, MAX(check_runs.completed_at) AS updated_at FROM homework_instances INNER JOIN assignments ON (homework_instances.id = assignments.homework_instance_id AND homework_instances.id IN (#{instances.join(',')})) INNER JOIN students ON (assignments.student_id = students.id) LEFT JOIN check_runs ON (assignments.id = check_runs.assignment_id) WHERE assignments.status NOT IN ('open', 'approved') GROUP BY assignments.id, assignments.status, homework_instances.name, prepare_deadline, approve_deadline, assignments.repo, assignments.url, students.login ORDER BY MAX(check_runs.completed_at)")
        .map
        .to_a
    end
  end
end
