class CompetitionRepository < Hanami::Repository
  def with_students
    competitions.read("SELECT homework_instance_id, assignment_id, login, score, name FROM competitions INNER JOIN assignments ON (competitions.assignment_id = assignments.id) INNER JOIN students ON (assignments.student_id = students.id)")
      .map
      .to_a
  end
end
