require 'spec_helper'

describe "examples/new" do
  before(:each) do
    assign(:example, stub_model(Example,
      :test => "MyString"
    ).as_new_record)
  end

  it "renders new example form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => examples_path, :method => "post" do
      assert_select "input#example_test", :name => "example[test]"
    end
  end
end
