class StudentRepository < Hanami::Repository
  def ordered
    students
      .order(:group, :last_name, :first_name, :login)
      .map_to(Student)
      .to_a
  end

  def by_login(login)
    students
      .where(login: login)
      .map_to(Student)
      .to_a
      .first
  end
end
