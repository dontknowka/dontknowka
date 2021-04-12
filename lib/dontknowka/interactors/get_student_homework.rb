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
      a = ass.filter {|a| a[:homework_set_name] == set}
      if a.empty?
        Homework.new(homework_set_name: set)
      else
        a.map {|x| Homework.new(x)}
      end
    end
  end

  private

  class Homework
    attr_reader :id, :set, :type, :name, :status, :colour, :url, :url_title, :worth, :prepare_before, :approve_before, :days_left, :days_left_style, :use_late_days

    def initialize(options)
      @id = options[:assignment_id]
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
      @days_left_style = ''
      deadline = case options[:status] || ''
                 when 'open'
                   options[:prepare_deadline]
                 when 'in_progress'
                   options[:prepare_deadline]
                 when 'ready'
                   options[:approve_deadline]
                 else
                   nil
                 end
      @use_late_days = false
      days = -1
      if !deadline.nil?
        days = (deadline - Time.now) / 86400
        if days < 0
          @days_left = 'X'
          @days_left_style = 'text-red'
        else
          @days_left = days.to_i
          @use_late_days = true
          @days_left_style = case @days_left
                             when proc {|n| n < 2}
                               'text-red'
                             when proc {|n| n < 5}
                               'text-orange'
                             else
                               'text-green'
                             end
        end
      end
      if options[:url].nil? || options[:url].empty?
        if days >= 0
          if !options[:classroom_url].nil? && !options[:classroom_url].empty?
            @url = options[:classroom_url]
          end
          @url_title = 'Activate'
        end
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
