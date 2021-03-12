class StudentRepository < Hanami::Repository
  def ordered
    students
      .order(:group, :last_name, :first_name, :login)
      .map_to(Student)
      .to_a
  end
end
