class TeacherTeamRepository < Hanami::Repository
  associations do
    has_many :teacher_to_teams
    has_many :teachers, through: :teacher_to_teams
  end
end
