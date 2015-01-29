require 'spec_helper'

describe "new_tests/new" do
  before(:each) do
    assign(:new_test, stub_model(NewTest,
      :game => "MyString",
      :score => 1
    ).as_new_record)
  end

  it "renders new new_test form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => new_tests_path, :method => "post" do
      assert_select "input#new_test_game", :name => "new_test[game]"
      assert_select "input#new_test_score", :name => "new_test[score]"
    end
  end
end
