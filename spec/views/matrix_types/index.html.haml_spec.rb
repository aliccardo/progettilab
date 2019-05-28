require 'rails_helper'

RSpec.describe "matrix_types/index", type: :view do
  before(:each) do
    assign(:matrix_types, [
      MatrixType.create!(
        :pid => 2,
        :title => "",
        :label => "",
        :body => "MyText",
        :radia => 3,
        :status => false
      ),
      MatrixType.create!(
        :pid => 2,
        :title => "",
        :label => "",
        :body => "MyText",
        :radia => 3,
        :status => false
      )
    ])
  end

  it "renders a list of matrix_types" do
    render
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
