class BonusRepository < Hanami::Repository
  associations do
    belongs_to :student
  end

  def with_students
    aggregate(:student)
      .map_to(Bonus)
      .to_a
  end
end
