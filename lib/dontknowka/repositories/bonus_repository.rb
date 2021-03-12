class BonusRepository < Hanami::Repository
  associations do
    belongs_to :student
  end

  def by_student(student)
    bonuses
      .where(student_id: student.id)
      .map_to(Bonus)
      .to_a
  end

  def with_students
    aggregate(:student)
      .map_to(Bonus)
      .to_a
  end
end
