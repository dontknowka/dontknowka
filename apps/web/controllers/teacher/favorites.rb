module Web
  module Controllers
    module Teacher
      class Favorites
        include Web::Action

        before :authenticate?

        expose :login
        expose :avatar

        expose :teacher_mapping
        expose :homework_instances

        def initialize(instances: HomeworkInstanceRepository.new,
                       teacher_mappings: TeacherMappingRepository.new)
          @instances = instances
          @teacher_mappings = teacher_mappings
        end

        def call(params)
          teacher_id = session[:github_id]
          current_mappings = @teacher_mappings.by_teacher(teacher_id)
          @homework_instances = @instances.with_homeworks
            .sort_by {|i| i.homework.prepare_deadline}
            .map {|i| Instance.new(i)}
          if params[:teacher_mapping]
            to_id = current_mappings.reduce(Hash[]) {|h, tm| h.merge({tm.homework_instance_id => tm.id})}
            @teacher_mapping = params[:teacher_mapping]
            @homework_instances.each do |hwi|
              instance_id = Instance.form_id_to_id(hwi.id)
              if @teacher_mapping[hwi.id] == '1'
                if to_id[instance_id].nil?
                  Hanami.logger.debug "Add mapping for #{instance_id}"
                  @teacher_mappings.create(teacher_id: teacher_id, homework_instance_id: instance_id)
                end
              else
                if !to_id[instance_id].nil?
                  Hanami.logger.debug "Remove mapping for #{instance_id}"
                  @teacher_mappings.delete(to_id[instance_id])
                end
              end
            end
          else
            @teacher_mapping = current_mappings.reduce(Hash[]) {|h, tm| h.merge({Instance.id_to_form_id(tm.homework_instance_id) => 1})}
          end
          @login = session[:login]
          @avatar = session[:avatar]
        end

        private

        def authenticate?
          authenticate! if session[:github_id].nil?
        end

        def authenticate!
          redirect_to routes.login_path
        end

        class Instance
          attr_reader :id, :name

          def initialize(hwi)
            @id = self.class.id_to_form_id(hwi.id)
            @name = hwi.name
          end

          def self.id_to_form_id(id)
            "hw#{id}".intern
          end

          def self.form_id_to_id(id)
            Integer(id.to_s[2..-1])
          end
        end
      end
    end
  end
end
