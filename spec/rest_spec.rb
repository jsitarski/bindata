#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), "spec_common"))
require 'jbindata/rest'

describe JBinData::Rest do
  it { should == "" }

  it "reads till end of stream" do
    data = "abcdefghij"
    subject.read(data).should == data
  end

  it "allows setting value for completeness" do
    subject.assign("123")
    subject.should == "123"
    subject.to_binary_s.should == "123"
  end

  it "accepts JBinData::BasePrimitive parameters" do
    rest = JBinData::Rest.new(:check_value => "abc")
    expect {
      rest.read("xyz")
    }.to raise_error(JBinData::ValidityError)
  end
end
