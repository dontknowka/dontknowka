require 'hanami/interactor'

class CreateTeam
  include Hanami::Interactor

  expose :ok

  def initialize(repo: TeacherTeamRepository.new)
    @repo = repo
  end

  def call(id, slug, name)
    begin
      team = @repo.find(id)
      if team.nil?
        @repo.create({ id: id, slug: slug, name: name })
      else
        @repo.update(id, { slug: slug,
                           name: name })
      end
      @ok = true
    rescue
      @ok = false
    end
  end
end
