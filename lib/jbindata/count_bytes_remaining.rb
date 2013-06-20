require "jbindata/base_primitive"

module JBinData
  # Counts the number of bytes remaining in the input stream from the current
  # position to the end of the stream.  This only makes sense for seekable
  # streams.
  #
  #   require 'jbindata'
  #
  #   class A <JBinData::Record
  #     count_bytes_remaining :bytes_remaining
  #     string :all_data, :read_length => :bytes_remaining
  #   end
  #
  #   obj = A.read("abcdefghij")
  #   obj.all_data #=> "abcdefghij"
  #
  class CountBytesRemaining < JBinData::BasePrimitive

    #---------------
    private

    def value_to_binary_string(val)
      ""
    end

    def read_and_return_value(io)
      io.num_bytes_remaining
    end

    def sensible_default
      0
    end
  end
end
