require 'spec_helper'

describe "work_orders/new" do
  before(:each) do
    assign(:work_order, stub_model(WorkOrder).as_new_record)
  end

  it "renders new work_order form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => work_orders_path, :method => "post" do
    end
  end
end
