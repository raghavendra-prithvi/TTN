require 'spec_helper'

describe "new_tests/edit" do
  before(:each) do
    @new_test = assign(:new_test, stub_model(NewTest,
      :game => "MyString",
      :score => 1
    ))
  end

  it "renders the edit new_test form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => new_tests_path(@new_test), :method => "post" do
      assert_select "input#new_test_game", :name => "new_test[game]"
      assert_select "input#new_test_score", :name => "new_test[score]"
    end
  end
end
