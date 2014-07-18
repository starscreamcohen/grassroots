require 'spec_helper'

describe Message do
  it {should belong_to(:recipient)}
  it {should belong_to(:conversation)}
end