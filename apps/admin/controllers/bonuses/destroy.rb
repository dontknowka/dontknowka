module Admin
  module Controllers
    module Bonuses
      class Destroy
        include Admin::Action

        def initialize(bonus_repo: BonusRepository.new)
          @bonus_repo = bonus_repo
        end

        def call(params)
          @bonus_repo.delete(params[:id])
          redirect_to routes.bonuses_path
        end
      end
    end
  end
end
