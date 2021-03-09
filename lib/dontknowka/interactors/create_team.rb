require 'hanami/interactor'

class CreateTeam
  include Hanami::Interactor

  expose :ok

  def initialize(repo: TeacherTeamRepository.new)
    @repo = repo
  end

  def call(id, slug, name)
    begin
      @repo.create({ id: id, slug: slug, name: name })
      @ok = true
    rescue
      @ok = false
    end
  end
end
