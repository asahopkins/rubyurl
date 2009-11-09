require File.dirname(__FILE__) + '/../../spec_helper'

describe "links/index" do
  before(:each) do
    render 'links/index'
  end

  it "should display Create a tinyThom.as Link in a h1 tag" do
    response.should have_tag('label', 'Create a tinyThom.as Link (original starts with "http://thomas.loc.gov/...")')
  end

  it "should display a text input field for the user to paste their url in" do
    response.should have_tag('input#link_website_url')
  end
end

describe "links/show" do

  before(:each) do
    @link = mock_model(Link)
    @link.stub!(:permalink).and_return('http://localhost:3000/x093')
    @link.stub!(:website_url).and_return('http://thomas.loc.gov/cgi-bin/query/z?r108:E26MR4-0014:')
    @link.stub!(:thomas_permalink).and_return('http://thomas.loc.gov/cgi-bin/query/z?r108:E26MR4-0014:')
    assigns[:link] = @link
    render 'links/show'
  end

  it "should display Here is your tinyThom.as in a h1 tag" do
    response.should have_tag('dt', 'Here is your tinyThom.as URL')
  end

  it "should display the submitted URL" do
    response.should have_tag('dd', 'http://thomas.loc.gov/cgi-bin/query/z?r108:E26MR4-0014:')
  end

  it "should display the Thomas permalink URL" do
    response.should have_tag('dd', 'http://thomas.loc.gov/cgi-bin/query/z?r108:E26MR4-0014:')
  end

  it "should display a link for the user to copy" do
    response.should have_tag('div#url')
    response.should have_tag('a', 'http://localhost:3000/x093')
  end

  it "should display the correct number of characters for the original URL (55)" do
    response.should have_tag('dd', '55 characters')
  end
end