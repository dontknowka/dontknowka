class TeamMappingRepository < Hanami::Repository
  associations do
    belongs_to :team
    belongs_to :homework_instance
  end

  def with_teams
    aggregate(:team)
      .map_to(TeamMapping)
      .to_a
  end

  def by_instance(id)
    aggregate(:team)
      .where(homework_instance_id: id)
      .map_to(TeamMapping)
      .one
  end
end
