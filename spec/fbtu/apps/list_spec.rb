require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

describe "fbtu apps list" do
  it "does not blow up when there's no dotfile" do
    File.unlink @fbtu_dotfile.path
    
    lambda do
      fbtu %w[apps list]
    end.should_not raise_error
  end
end
