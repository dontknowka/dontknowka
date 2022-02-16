require 'ostruct'

RSpec.describe GetStudentScore do
  let(:interactor) { described_class.new(assignment_repo: assignments, bonus_repo: bonuses) }
  let(:assignments) { instance_double('AssignmentRepository') }
  let(:bonuses) { instance_double('BonusRepository') }

  let(:student) { 'some student' }

  let(:open_ass) { OpenStruct.new(status: 'open') }
  let(:in_progress_ass) { OpenStruct.new(status: 'in_progress') }
  let(:ready_ass) { OpenStruct.new(status: 'ready') }
  let(:failed_ass) { OpenStruct.new(status: 'failed') }
  let(:no_malus_ass) { OpenStruct.new(status: 'approved',
                                      homework_instance: big_hw_instance,
                                      check_runs: [cr1],
                                      interview: good_interview,
                                      reviews: []) }
  let(:small_criticism_ass) { OpenStruct.new(status: 'approved',
                                             homework_instance: big_hw_instance,
                                             check_runs: [cr1, cr1, cr1, cr2],
                                             reviews: [rev1]) }
  let(:small_hw_two_reviews_ass) { OpenStruct.new(status: 'approved',
                                                  homework_instance: small_hw_instance,
                                                  check_runs: [cr1, cr2],
                                                  reviews: [rev1, rev2]) }
  let(:excellent_interview_ass) { OpenStruct.new(status: 'approved',
                                                 homework_instance: big_hw_instance,
                                                 check_runs: [cr1],
                                                 reviews: [rev1, rev2],
                                                 interview: excelent_interview) }
  let(:bad_interview_ass) { OpenStruct.new(status: 'approved',
                                           homework_instance: big_hw_instance,
                                           check_runs: [cr1, cr2],
                                           reviews: [],
                                           interview: poor_interview) }
  let(:many_reviews_ass) { OpenStruct.new(status: 'approved',
                                          homework_instance: big_hw_instance,
                                          check_runs: [cr1],
                                          reviews: [rev1, rev2, rev3]) }
  let(:many_check_runs_ass) { OpenStruct.new(status: 'approved',
                                             homework_instance: small_hw_instance,
                                             reviews: [],
                                             check_runs: [cr1, cr2, cr1, cr2, cr1, cr2, cr1, cr2, cr1, cr2, cr1, cr2, cr1, cr2, cr1, cr2, cr1, cr1, cr1]) }

  let(:small_hw_instance) { OpenStruct.new(name: 'M1', worth: 12) }
  let(:big_hw_instance) { OpenStruct.new(name: 'B2', worth: 25) }

  let(:cr1) { OpenStruct.new(pull: 1) }
  let(:cr2) { OpenStruct.new(pull: 2) }

  let(:rev1) { OpenStruct.new(submitted_at: 1, number_of_criticism: 1) }
  let(:rev2) { OpenStruct.new(submitted_at: 2, number_of_criticism: 0) }
  let(:rev3) { OpenStruct.new(submitted_at: 3, number_of_criticism: 5) }

  let(:excelent_interview) { OpenStruct.new(malus: 5) }
  let(:good_interview) { OpenStruct.new(malus: 0) }
  let(:poor_interview) { OpenStruct.new(malus: -10) }

  let(:bonus) { OpenStruct.new(worth: 5) }
  let(:malus) { OpenStruct.new(worth: -7) }

  it 'produces zero with no assignments' do
    expect(assignments).to receive(:with_reviews).with(student).and_return([])
    expect(bonuses).to receive(:by_student).with(student).and_return([])
    result = interactor.call(student)
    expect(result.total).to eq 0
    expect(result.bonuses).to eq []
    expect(result.assignments).to eq []
  end

  it 'produces zero with no approved assignments' do
    expect(assignments).to receive(:with_reviews).with(student).and_return([open_ass, failed_ass, ready_ass])
    expect(bonuses).to receive(:by_student).with(student).and_return([])
    result = interactor.call(student)
    expect(result.total).to eq 0
    expect(result.bonuses).to eq []
    expect(result.assignments).to eq []
  end

  it 'produces total equal to bonus score with no assignments' do
    expect(assignments).to receive(:with_reviews).with(student).and_return([])
    expect(bonuses).to receive(:by_student).with(student).and_return([bonus])
    result = interactor.call(student)
    expect(result.total).to eq 5
    expect(result.bonuses).to eq [bonus]
    expect(result.assignments).to eq []
  end

  it 'produces nominal worth for an assignment without any malus' do
    expect(assignments).to receive(:with_reviews).with(student).and_return([no_malus_ass])
    expect(bonuses).to receive(:by_student).with(student).and_return([])
    result = interactor.call(student)
    expect(result.total).to eq 25
    expect(result.bonuses).to eq []
    expect(result.assignments.size).to eq 1
  end

  it 'produces expected worth for an assignment with small criticism' do
    expect(assignments).to receive(:with_reviews).with(student).and_return([small_criticism_ass])
    expect(bonuses).to receive(:by_student).with(student).and_return([])
    result = interactor.call(student)
    expect(result.total).to eq 24
    expect(result.bonuses).to eq []
    expect(result.assignments.size).to eq 1
  end

  it 'produces expected worth for a small assignment with two mild reviews' do
    expect(assignments).to receive(:with_reviews).with(student).and_return([small_hw_two_reviews_ass])
    expect(bonuses).to receive(:by_student).with(student).and_return([])
    result = interactor.call(student)
    expect(result.total).to eq 10
    expect(result.bonuses).to eq []
    expect(result.assignments.size).to eq 1
  end

  it 'produces expected worth for an assignment with an excellent interview' do
    expect(assignments).to receive(:with_reviews).with(student).and_return([excellent_interview_ass])
    expect(bonuses).to receive(:by_student).with(student).and_return([])
    result = interactor.call(student)
    expect(result.total).to eq 26
    expect(result.bonuses).to eq []
    expect(result.assignments.size).to eq 1
  end

  it 'produces expected worth for an assignment with a poor interview' do
    expect(assignments).to receive(:with_reviews).with(student).and_return([bad_interview_ass])
    expect(bonuses).to receive(:by_student).with(student).and_return([])
    result = interactor.call(student)
    expect(result.total).to eq 15
    expect(result.bonuses).to eq []
    expect(result.assignments.size).to eq 1
  end

  it 'produces expected worth for an assignment with a lot of reviews' do
    expect(assignments).to receive(:with_reviews).with(student).and_return([many_reviews_ass])
    expect(bonuses).to receive(:by_student).with(student).and_return([])
    result = interactor.call(student)
    expect(result.total).to eq 13
    expect(result.bonuses).to eq []
    expect(result.assignments.size).to eq 1
  end

  it 'produces expected worth for an assignment with a lot of check runs' do
    expect(assignments).to receive(:with_reviews).with(student).and_return([many_check_runs_ass])
    expect(bonuses).to receive(:by_student).with(student).and_return([])
    result = interactor.call(student)
    expect(result.total).to eq 11
    expect(result.bonuses).to eq []
    expect(result.assignments.size).to eq 1
  end
end
