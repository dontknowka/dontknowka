require 'hanami/interactor'

class CreateTeacher
  include Hanami::Interactor

  expose :ok

  def initialize(repo: TeacherRepository.new)
    @repo = repo
  end

  def call(id, login, name, email, avatar)
    name_parts = (name || '').split
    begin
      @repo.create({ id: id,
                     login: login,
                     first_name: name_parts[0],
                     last_name: name_parts[1] || '',
                     email: email || '',
                     avatar: avatar })
      @ok = true
    rescue
      @ok = false
    end
  end
end
