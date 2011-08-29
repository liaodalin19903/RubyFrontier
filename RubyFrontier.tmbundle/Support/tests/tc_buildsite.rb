require "test/unit"

# load the whole RubyFrontier world
require File.dirname(File.dirname(File.expand_path(__FILE__))) + '/bin/RubyFrontier/longestJourney.rb'

class TestBuilding < Test::Unit::TestCase
  #require (File.dirname(__FILE__)) + '/stdoutRedirectionForTesting.rb'
  #include RedirectIo
  
  def test_classMethods
    p = (Pathname(__FILE__).dirname + "testsites") + "site1"
    f1 = p + "#template.txt"
    f2 = p + "firstpage.txt"
    f3 = p + "biteme.txt"
    f4 = p + (p + "folder") + "fourthpage.txt"
    # guaranteePageOfSite
    assert_raise(RuntimeError) do
      UserLand::Html.guaranteePageOfSite(f3) # non-existent raises
    end
    assert_raise(RuntimeError) do
      UserLand::Html.guaranteePageOfSite(f1) # non-page raises
    end
    assert_nothing_raised do
      UserLand::Html.guaranteePageOfSite(f2) # real page, nothing happens
    end
    # getFtpSiteFile
    assert_raise(RuntimeError) do
      UserLand::Html.getFtpSiteFile(__FILE__) # not in a site, raises
    end
    assert_equal(p + "#ftpSite.yaml", UserLand::Html.getFtpSiteFile(f1)) # works with non-page
    assert_equal(p + "#ftpSite.yaml", UserLand::Html.getFtpSiteFile(f2)) # works with page
    assert_equal(p + "#ftpSite.yaml", UserLand::Html.getFtpSiteFile(f3)) # works with non-existent page, provided folder exists
    assert_equal(p + "#ftpSite.yaml", UserLand::Html.getFtpSiteFile(f4)) # works with deeper page
    # everyPageOfFolder
    arr = UserLand::Html.everyPageOfFolder(p).map {|aPage| aPage.simplename.to_s}.sort
    assert_equal(%w{firstpage fourthpage secondpage thirdpage}, arr) # includes page objects at all depths down
    arr = UserLand::Html.everyPageOfFolder(f4.dirname).map {|aPage| aPage.simplename.to_s}.sort
    assert_equal(%w{ fourthpage }, arr) # but does not go up, of course
    # everyPageOfSite 
    # lists all page objects even if we start with a non-page
    arr = UserLand::Html.everyPageOfSite(f1).map {|aPage| aPage.simplename.to_s}.sort
    assert_equal(%w{firstpage fourthpage secondpage thirdpage}, arr)
    arr = UserLand::Html.everyPageOfSite(f2).map {|aPage| aPage.simplename.to_s}.sort
    assert_equal(%w{firstpage fourthpage secondpage thirdpage}, arr)
    arr = UserLand::Html.everyPageOfSite(f4).map {|aPage| aPage.simplename.to_s}.sort
    assert_equal(%w{firstpage fourthpage secondpage thirdpage}, arr)
    # html.getLink - linetext, url, options hash
    s = UserLand::Html.getLink("biteme", "url")
    assert_equal(%{<a href="url">biteme</a>}, s)
    s = UserLand::Html.getLink("biteme", "url", :crap => "crud", :bite => "me")
    assert_equal(%{<a href="url" crap="crud" bite="me">biteme</a>}, s)
    s = UserLand::Html.getLink("biteme", "url", :crap => "crud", :bite => "me", :anchor => "anc")
    assert_equal(%{<a href="url#anc" crap="crud" bite="me">biteme</a>}, s)
    s = UserLand::Html.getLink("biteme", "url", :crap => "crud", :bite => "me", :anchor => "#anc")
    assert_equal(%{<a href="url#anc" crap="crud" bite="me">biteme</a>}, s)
    s = UserLand::Html.getLink("biteme", "url", :crap => "crud", :bite => "me", :anchor => "#anc", :othersite => "other")
    assert_equal(%{<a href="other^url#anc" crap="crud" bite="me">biteme</a>}, s)
    
    
    # trying to build a non-page raises an error
    assert_raise(RuntimeError) do
      UserLand::Html.releaseRenderedPage(f1, false, false)
    end
    # in particular, trying to build a non-page raises an error that says *this*
    begin
      UserLand::Html.releaseRenderedPage(f1, false, false)
    rescue
      assert_match /not a site page/, $!.message
    end
    
    # releaseRenderedPage, publishSite, publishFolder
    
  end
  
end
