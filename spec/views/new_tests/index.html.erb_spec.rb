require 'spec_helper'

describe "new_tests/index" do
  before(:each) do
    assign(:new_tests, [
      stub_model(NewTest,
        :game => "Game",
        :score => 1
      ),
      stub_model(NewTest,
        :game => "Game",
        :score => 1
      )
    ])
  end

  it "renders a list of new_tests" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Game".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
