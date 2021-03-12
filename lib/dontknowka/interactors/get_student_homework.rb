require 'hanami/interactor'

class GetStudentHomework
  include Hanami::Interactor

  expose :list

  def initialize(assignments: AssignmentRepository.new,
                 homework_sets: HomeworkSetRepository.new)
    @assignments = assignments
    @homework_sets = homework_sets
  end

  def call(student)
    ass = @assignments.with_sets(student)
    @list = @homework_sets.all_set_names.flat_map do |set|
      a = ass.detect { |a| a[:homework_set_name] == set }
      if a.nil?
        Homework.new(homework_set_name: set)
      else
        Homework.new(a)
      end
    end
  end

  private

  class Homework
    attr_reader :set, :type, :name, :status, :colour, :url, :url_title, :worth, :prepare_before, :approve_before

    def initialize(options)
      @set = options[:homework_set_name]
      @type = options[:homework_kind] + options[:homework_number].to_s if !options[:homework_kind].nil?
      @name = options[:homework_instance_name]
      @status = (options[:status] || '').capitalize.gsub('_', ' ')
      @colour = case options[:status]
                when 'in_progress'
                  'yellow'
                when 'ready'
                  'pink'
                when 'approved'
                  'green'
                when 'failed'
                  'red'
                end
      if options[:url].nil? || options[:url].empty?
        @url = options[:classroom_url]
        @url_title = 'Activate'
      else
        @url = options[:url]
        @url_title = 'Go to repo'
      end
      @worth = options[:worth]
      if !options[:prepare_deadline].nil?
        @prepare_before = options[:prepare_deadline].strftime("%d.%m.%Y %H:%M:%S")
        @approve_before = options[:approve_deadline].strftime("%d.%m.%Y %H:%M:%S")
      end
    end
  end
end
