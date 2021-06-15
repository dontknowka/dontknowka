class CompetitionRepository < Hanami::Repository
  def with_students
    competitions.read("SELECT homework_instance_id, assignment_id, login, score, name FROM competitions INNER JOIN assignments ON (competitions.assignment_id = assignments.id) INNER JOIN students ON (assignments.student_id = students.id)")
      .map
      .to_a
  end

  def delete_by_assignment(id)
    competitions
      .where(assignment_id: id)
      .delete
  end

  def lookup(assignment_id, name)
    competitions
      .where(assignment_id: assignment_id, name: name)
      .map_to(Competition)
      .to_a
  end
end
