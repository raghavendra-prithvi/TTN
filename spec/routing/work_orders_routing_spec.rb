require "spec_helper"

describe WorkOrdersController do
  describe "routing" do

    it "routes to #index" do
      get("/work_orders").should route_to("work_orders#index")
    end

    it "routes to #new" do
      get("/work_orders/new").should route_to("work_orders#new")
    end

    it "routes to #show" do
      get("/work_orders/1").should route_to("work_orders#show", :id => "1")
    end

    it "routes to #edit" do
      get("/work_orders/1/edit").should route_to("work_orders#edit", :id => "1")
    end

    it "routes to #create" do
      post("/work_orders").should route_to("work_orders#create")
    end

    it "routes to #update" do
      put("/work_orders/1").should route_to("work_orders#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/work_orders/1").should route_to("work_orders#destroy", :id => "1")
    end

  end
end
