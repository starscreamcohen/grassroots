require 'spec_helper'

describe Talent do
  it { should belong_to(:user)}
  it { should belong_to(:skill)}
end