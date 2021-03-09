RSpec.describe Admin::Views::TeacherMappings::Index, type: :view do
  let(:exposures) { Hash[format: :html] }
  let(:template)  { Hanami::View::Template.new('apps/admin/templates/teacher_mappings/index.html.erb') }
  let(:view)      { described_class.new(template, exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    expect(view.format).to eq exposures.fetch(:format)
  end
end
