module Admin
  module Controllers
    module Bonuses
      class Update
        include Admin::Action

        def initialize(bonus_repo: BonusRepository.new)
          @bonus_repo = bonus_repo
        end

        def call(params)
          @bonus_repo.update(params[:id], params[:bonus])
          redirect_to routes.bonuses_path
        end
      end
    end
  end
end
