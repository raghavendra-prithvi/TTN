require 'spec_helper'

describe "new_tests/show" do
  before(:each) do
    @new_test = assign(:new_test, stub_model(NewTest,
      :game => "Game",
      :score => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Game/)
    rendered.should match(/1/)
  end
end
