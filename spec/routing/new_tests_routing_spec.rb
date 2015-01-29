require "spec_helper"

describe NewTestsController do
  describe "routing" do

    it "routes to #index" do
      get("/new_tests").should route_to("new_tests#index")
    end

    it "routes to #new" do
      get("/new_tests/new").should route_to("new_tests#new")
    end

    it "routes to #show" do
      get("/new_tests/1").should route_to("new_tests#show", :id => "1")
    end

    it "routes to #edit" do
      get("/new_tests/1/edit").should route_to("new_tests#edit", :id => "1")
    end

    it "routes to #create" do
      post("/new_tests").should route_to("new_tests#create")
    end

    it "routes to #update" do
      put("/new_tests/1").should route_to("new_tests#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/new_tests/1").should route_to("new_tests#destroy", :id => "1")
    end

  end
end
