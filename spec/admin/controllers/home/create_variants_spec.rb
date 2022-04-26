require 'ostruct'

RSpec.describe Admin::Controllers::Home::CreateVariants, type: :action do
  let(:action) { described_class.new(homework_sets: sets, assignments: assignments) }
  let(:params) { { 'rack.session' => session } }

  let(:sets) { instance_double('HomeworkSetRepository') }
  let(:assignments) { instance_double('AssignmentRepository') }

  let(:hw_name_1) { 'M1' }
  let(:hw_i_1) { 11 }
  let(:hw_prepare_1) { 'aaa' }
  let(:hw_approve_1) { 111 }
  let(:hw_name_2) { 'B1' }
  let(:hw_i_2) { 37 }
  let(:hw_prepare_2) { 'bbb' }
  let(:hw_approve_2) { 333 }
  let(:hw_name_3) { 'B2' }
  let(:hw_i_3) { 97 }
  let(:hw_prepare_3) { 'bbb' }
  let(:hw_approve_3) { 333 }
  let(:single_variant) { OpenStruct.new(name: hw_name_1,
                                        variant_id: 1,
                                        instances: [hw_i_1],
                                        homeworks: [{ id: hw_i_1,
                                                      name: hw_name_1,
                                                      variant_id: 1,
                                                      homework_instance_name: hw_name_1,
                                                      prepare_deadline: hw_prepare_1,
                                                      approve_deadline: hw_approve_1 }]) }
  let(:multi_variant) { OpenStruct.new(name: 'B',
                                       variant_id: 2,
                                       instances: [hw_i_2, hw_i_3],
                                       homeworks: [{ id: hw_i_2,
                                                     name: 'B',
                                                     variant_id: 2,
                                                     homework_instance_name: hw_name_2,
                                                     prepare_deadline: hw_prepare_2,
                                                     approve_deadline: hw_approve_2 },
                                                   { id: hw_i_3,
                                                     name: 'B',
                                                     variant_id: 2,
                                                     homework_instance_name: hw_name_3,
                                                     prepare_deadline: hw_prepare_3,
                                                     approve_deadline: hw_approve_3 }]) }

  let(:student_a) { OpenStruct.new(id: 7, login: 'aaa-bcd') }
  let(:student_b) { OpenStruct.new(id: 13, login: 'xxx') }

  context 'when user is logged in' do
    let(:session) { { logged_in: true } }

    it 'is successful' do
      expect(sets).to receive(:all_variants).and_return([single_variant, multi_variant])
      expect(assignments).to receive(:group_by_student).and_return({ student_a.id => [ { student_id: student_a.id, login: student_a.login, homework_instance_id: hw_i_1 }],
                                                                     student_b.id => [ { student_id: student_b.id, login: student_b.login, homework_instance_id: hw_i_1 },
                                                                                       { student_id: student_b.id, login: student_b.login, homework_instance_id: hw_i_2 }] })
      expect(assignments).to receive(:create).with(student_id: student_b.id,
                                                   homework_instance_id: hw_i_3,
                                                   prepare_deadline: hw_prepare_3,
                                                   approve_deadline: hw_approve_3,
                                                   url: '',
                                                   repo: "#{hw_name_3}-#{student_b.login}")
      response = action.call(params)
      expect(response[0]).to eq 302
      expect(response[1]['Location']).to eq '/admin'
    end
  end

  context 'when user is not logged in' do
    let(:session) { }

    it 'is redirected to login page' do
      expect(sets).not_to receive(:all_variants)
      expect(assignments).not_to receive(:group_by_student)
      response = action.call(params)
      expect(response[0]).to eq 302
      expect(response[1]['Location']).to eq '/admin/login'
    end
  end
end
