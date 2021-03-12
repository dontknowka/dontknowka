module Admin
  module Controllers
    module Homeworks
      class Show
        include Admin::Action

        expose :homework
        expose :total
        expose :name
        expose :instances
        expose :colours

        def initialize(homework_repo: HomeworkRepository.new)
          @homework_repo = homework_repo
        end

        def call(params)
          @homework = @homework_repo.find(params[:id])
          halt 404 if @homework.nil?
          @name = @homework.kind + @homework.number.to_s
          data = @homework_repo.with_assignments(params[:id])
          @total = data.size
          @instances = data.group_by {|x| x[:homework_instance_name]}
          @colours = { 'open' => '',
                       'in_progress' => 'Label--yellow',
                       'ready' => 'Label--pink',
                       'approved' => 'Label--green',
                       'failed' => 'Label--red' }
        end
      end
    end
  end
end
