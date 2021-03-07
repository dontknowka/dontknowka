class TeacherMappingRepository < Hanami::Repository
  associations do
    belongs_to :teacher
    belongs_to :homework_instance
  end

  def with_teachers
    aggregate(:teacher)
      .map_to(TeacherMapping)
      .to_a
  end

  def by_instance(id)
    aggregate(:teacher)
      .where(homework_instance_id: id)
      .map_to(TeacherMapping)
      .one
  end
end
