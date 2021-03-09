class TeamMappingRepository < Hanami::Repository
  associations do
    belongs_to :teacher_team
    belongs_to :homework_instance
  end

  def with_teams
    aggregate(:teacher_team)
      .map_to(TeamMapping)
      .to_a
  end

  def by_instance(id)
    aggregate(:teacher_team)
      .where(homework_instance_id: id)
      .map_to(TeamMapping)
      .one
  end
end
