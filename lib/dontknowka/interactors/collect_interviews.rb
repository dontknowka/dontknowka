require 'hanami/interactor'

class CollectInterviews
  include Hanami::Interactor

  expose :success
  expose :comment

  def initialize(assignments: AssignmentRepository.new,
                 fetch_comments: FetchComments.new,
                 interviews: InterviewRepository.new)
    @assignments = assignments
    @fetch_comments = fetch_comments
    @interviews = interviews
  end

  def call(homework_instance_id)
    @success = true
    @assignments.all_by_instance(homework_instance_id).each do |ass|
      res = @fetch_comments.call(ass.repo)
      if res.success
        interview = res.comments.filter {|c| (c[:body] || "").match? 'Interview: \[\s*([-0-9]+)\s*\]'}.last
        if !interview.nil?
          id = interview[:id]
          if interview[:user].nil?
            @success = false
            @comment = "Comment doesn't have an author: #{id}"
            break
          end
          teacher = interview[:user][:id]
          submitted_at = interview[:submitted_at] || interview[:created_at]
          if submitted_at.nil?
            @success = false
            @comment = "Missing timestamp on #{interview[:html_url]}"
            break
          end
          url = interview[:html_url]
          malus = interview[:body].match('Interview: \[\s*([-0-9]+)\s*\]') {|m| Integer(m[1])}
          if malus.nil?
            @success = false
            @comment = "Failed to parse interview comment: #{interview[:body]} for #{interview[:html_url]}"
            break
          end
          if !@interviews.find(id)
            @interviews.create(id: id,
                               assignment_id: ass.id,
                               teacher_id: teacher,
                               submitted_at: submitted_at,
                               malus: malus,
                               url: url)
          else
            @interviews.update(id,
                               assignment_id: ass.id,
                               teacher_id: teacher,
                               submitted_at: submitted_at,
                               malus: malus,
                               url: url)
          end
        end
      else
        @success = res.success
        @comment = res.comment
        break
      end
    end
  end
end
