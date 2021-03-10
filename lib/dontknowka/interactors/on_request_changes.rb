require 'hanami/interactor'

class OnRequestChanges
  include Hanami::Interactor

  expose :success
  expose :comment

  def initialize(review_creator: ReviewCreator.new)
    @review_creator = review_creator
  end

  def call(payload)
    review = payload[:review]
    author = review[:user] || {}
    pull = payload[:pull_request] || {}
    repo = payload[:repository] || {}
    if author[:id].nil?
      @success = false
      @comment = 'No review author data'
    elsif pull[:number].nil?
      @success = false
      @comment = 'No pull request data'
    elsif repo[:full_name].nil?
      @success = false
      @comment = 'No repository data'
    else
      res = @review_creator.call(review[:id],
                                 author[:id],
                                 repo[:full_name],
                                 pull[:number],
                                 review[:submitted_at],
                                 review[:body] || '',
                                 review[:html_url] || '')
      @success = res.success
      @comment = res.comment
    end
  end
end
