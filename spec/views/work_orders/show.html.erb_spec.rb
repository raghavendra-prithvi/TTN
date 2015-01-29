require 'spec_helper'

describe "work_orders/show" do
  before(:each) do
    @work_order = assign(:work_order, stub_model(WorkOrder))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
