require 'spec_helper'

describe "work_orders/index" do
  before(:each) do
    assign(:work_orders, [
      stub_model(WorkOrder),
      stub_model(WorkOrder)
    ])
  end

  it "renders a list of work_orders" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
