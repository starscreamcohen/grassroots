require 'spec_helper'

describe Accomplishment do
  it { should belong_to(:user)}
  it { should belong_to(:badge)}
end