require 'spec_helper'

describe "apps/index" do
  before(:each) do
    assign(:viewer_apps, [
      stub_model(App),
      stub_model(App)
    ])
    assign(:admin_apps, [
      stub_model(App),
      stub_model(App)
    ])
  end

  it "renders a list of apps" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
