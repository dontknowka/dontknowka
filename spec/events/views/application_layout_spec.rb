require "spec_helper"

RSpec.describe Events::Views::ApplicationLayout, type: :view do
  let(:layout)   { Events::Views::ApplicationLayout.new({ format: :html }, "contents") }
  let(:rendered) { layout.render }

  it 'contains application name' do
    expect(rendered).to include('Events')
  end
end
