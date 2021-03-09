class TeacherToTeamRepository < Hanami::Repository
  associations do
    belongs_to :teacher
    belongs_to :teacher_team
  end
end
