require 'spec_helper'

describe "work_orders/edit" do
  before(:each) do
    @work_order = assign(:work_order, stub_model(WorkOrder))
  end

  it "renders the edit work_order form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => work_orders_path(@work_order), :method => "post" do
    end
  end
end
