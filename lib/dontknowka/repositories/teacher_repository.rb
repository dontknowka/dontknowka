class TeacherRepository < Hanami::Repository
  associations do
    has_many :teacher_to_teams
    has_many :teacher_teams, through: :teacher_to_teams
  end

  def teachers_with_teams
    aggregate(:teacher_teams)
      .map_to(Teacher)
      .to_a
  end
end
