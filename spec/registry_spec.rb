#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), "spec_common"))
require 'jbindata/bits'
require 'jbindata/int'
require 'jbindata/float'
require 'jbindata/registry'

describe JBinData::Registry do
  A = Class.new
  B = Class.new
  C = Class.new
  D = Class.new

  let(:r) {JBinData::Registry.new }

  it "lookups registered names" do
    r.register('ASubClass', A)
    r.register('AnotherSubClass', B)

    r.lookup('ASubClass').should == A
    r.lookup('a_sub_class').should == A
    r.lookup('AnotherSubClass').should == B
    r.lookup('another_sub_class').should == B
  end

  it "does not lookup unregistered names" do
    expect {
      r.lookup('a_non_existent_sub_class')
    }.to raise_error(JBinData::UnRegisteredTypeError)
  end

  it "unregisters names" do
    r.register('ASubClass', A)
    r.unregister('ASubClass')

    expect {
      r.lookup('ASubClass')
    }.to raise_error(JBinData::UnRegisteredTypeError)
  end

  it "allows overriding of registered classes" do
    r.register('A', A)
    r.register('A', B)

    r.lookup('a').should == B
  end

  it "converts CamelCase to underscores" do
    r.underscore_name('CamelCase').should == 'camel_case'
  end

  it "converts adjacent caps camelCase to underscores" do
    r.underscore_name('XYZCamelCase').should == 'xyz_camel_case'
  end

  it "ignores the outer nestings of classes" do
    r.underscore_name('A::B::C').should == 'c'
  end
end

describe JBinData::Registry, "with numerics" do
  let(:r) {JBinData::RegisteredClasses }

  it "lookup integers with endian" do
    r.lookup("int24", :big).to_s.should == "JBinData::Int24be"
    r.lookup("int24", :little).to_s.should == "JBinData::Int24le"
    r.lookup("uint24", :big).to_s.should == "JBinData::Uint24be"
    r.lookup("uint24", :little).to_s.should == "JBinData::Uint24le"
  end

  it "does not lookup integers without endian" do
    expect {
      r.lookup("int24")
    }.to raise_error(JBinData::UnRegisteredTypeError)
  end

  it "does not lookup non byte based integers" do
    expect {
      r.lookup("int3")
    }.to raise_error(JBinData::UnRegisteredTypeError)
    expect {
      r.lookup("int3", :big)
    }.to raise_error(JBinData::UnRegisteredTypeError)
    expect {
      r.lookup("int3", :little)
    }.to raise_error(JBinData::UnRegisteredTypeError)
  end

  it "lookup floats with endian" do
    r.lookup("float", :big).to_s.should == "JBinData::FloatBe"
    r.lookup("float", :little).to_s.should == "JBinData::FloatLe"
    r.lookup("double", :big).to_s.should == "JBinData::DoubleBe"
    r.lookup("double", :little).to_s.should == "JBinData::DoubleLe"
  end

  it "lookup bits" do
    r.lookup("bit5").to_s.should == "JBinData::Bit5"
    r.lookup("bit6le").to_s.should == "JBinData::Bit6le"
  end

  it "lookup bits by ignoring endian" do
    r.lookup("bit2", :big).to_s.should == "JBinData::Bit2"
    r.lookup("bit3le", :big).to_s.should == "JBinData::Bit3le"
    r.lookup("bit2", :little).to_s.should == "JBinData::Bit2"
    r.lookup("bit3le", :little).to_s.should == "JBinData::Bit3le"
  end
end
