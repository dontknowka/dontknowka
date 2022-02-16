require 'ostruct'

RSpec.describe OnCheckRunCompleted do
  let(:interactor) { described_class.new(update_assignment: update) }
  let(:update) { instance_double('UpdateAssignmentCheck') }

  let(:success) { OpenStruct.new(success: true, comment: '') }

  context 'no associated pull request' do
    let(:check_run) { { name: 'build',
                        conclusion: 'success',
                        id: 111,
                        pull_requests: [] } }
    it 'misses repo name' do
      expect(update).not_to receive(:call)
      result = interactor.call(check_run: check_run)
      expect(result.success).to be false
      expect(result.comment).to eq 'No associated repository'
    end

    it 'succeeds with repo name from repository payload' do
      expect(update).to receive(:call).and_return(success)
      result = interactor.call(check_run: check_run, repository: { name: 'foo' })
      expect(result.success).to be true
    end
  end

  context 'with an associated pull request' do
    let(:check_run) { { name: 'build',
                        conclusion: 'success',
                        id: 111,
                        pull_requests: [ { number: 2,
                                           head: { repo: { name: 'some-repo' } } } ] } }
    it 'succeds with repo name from pull request' do
      expect(update).to receive(:call).with('some-repo', any_args).and_return(success)
      result = interactor.call(check_run: check_run)
      expect(result.success).to be true
    end

    it 'succeeds with repo name from repository payload' do
      expect(update).to receive(:call).with('foo', any_args).and_return(success)
      result = interactor.call(check_run: check_run, repository: { name: 'foo' })
      expect(result.success).to be true
    end
  end
end
