require 'jbindata/base'
require 'jbindata/dsl'

module JBinData
  # A Choice is a collection of data objects of which only one is active
  # at any particular time.  Method calls will be delegated to the active
  # choice.
  #
  #   require 'jbindata'
  #
  #   type1 = [:string, {:value => "Type1"}]
  #   type2 = [:string, {:value => "Type2"}]
  #
  #   choices = {5 => type1, 17 => type2}
  #   a =JBinData::Choice.new(:choices => choices, :selection => 5)
  #   a # => "Type1"
  #
  #   choices = [ type1, type2 ]
  #   a =JBinData::Choice.new(:choices => choices, :selection => 1)
  #   a # => "Type2"
  #
  #   choices = [ nil, nil, nil, type1, nil, type2 ]
  #   a =JBinData::Choice.new(:choices => choices, :selection => 3)
  #   a # => "Type1"
  #
  #
  #   Chooser = Struct.new(:choice)
  #   mychoice = Chooser.new
  #   mychoice.choice = 'big'
  #
  #   choices = {'big' => :uint16be, 'little' => :uint16le}
  #   a =JBinData::Choice.new(:choices => choices, :copy_on_change => true,
  #                           :selection => lambda { mychoice.choice })
  #   a.assign(256)
  #   a.to_binary_s #=> "\001\000"
  #
  #   mychoice.choice = 'little'
  #   a.to_binary_s #=> "\000\001"
  #
  # == Parameters
  #
  # Parameters may be provided at initialisation to control the behaviour of
  # an object.  These params are:
  #
  # <tt>:choices</tt>::        Either an array or a hash specifying the possible
  #                            data objects.  The format of the
  #                            array/hash.values is a list of symbols
  #                            representing the data object type.  If a choice
  #                            is to have params passed to it, then it should
  #                            be provided as [type_symbol, hash_params].  An
  #                            implementation constraint is that the hash may
  #                            not contain symbols as keys, with the exception
  #                            of :default.  :default is to be used when then
  #                            :selection does not exist in the :choices hash.
  # <tt>:selection</tt>::      An index/key into the :choices array/hash which
  #                            specifies the currently active choice.
  # <tt>:copy_on_change</tt>:: If set to true, copy the value of the previous
  #                            selection to the current selection whenever the
  #                            selection changes.  Default is false.
  class Choice < JBinData::Base
    include DSLMixin

    dsl_parser :choice

    mandatory_parameters :choices, :selection
    optional_parameter   :copy_on_change

    class << self

      def sanitize_parameters!(params) #:nodoc:
        params.merge!(dsl_params)

        if params.needs_sanitizing?(:choices)
          choices = choices_as_hash(params[:choices])
          ensure_valid_keys(choices)
          params[:choices] = params.create_sanitized_choices(choices)
        end
      end

      #-------------
      private

      def choices_as_hash(choices)
        if choices.respond_to?(:to_ary)
          key_array_by_index(choices.to_ary)
        else
          choices
        end
      end

      def key_array_by_index(array)
        result = {}
        array.each_with_index do |el, i|
          result[i] = el unless el.nil?
        end
        result
      end

      def ensure_valid_keys(choices)
        if choices.has_key?(nil)
          raise ArgumentError, ":choices hash may not have nil key"
        end
        if choices.keys.detect { |key| key.is_a?(Symbol) and key != :default }
          raise ArgumentError, ":choices hash may not have symbols for keys"
        end
      end
    end

    def initialize_shared_instance
      if eval_parameter(:copy_on_change) == true
        class << self
          alias_method :hook_after_current_choice, :copy_previous_value
        end
      end
    end

    def initialize_instance
      @choices = {}
      @last_selection = nil
    end

    # A convenience method that returns the current selection.
    def selection
      eval_parameter(:selection)
    end

    def clear #:nodoc:
      current_choice.clear
    end

    def clear? #:nodoc:
      current_choice.clear?
    end

    def assign(val)
      current_choice.assign(val)
    end

    def snapshot
      current_choice.snapshot
    end

    def respond_to?(symbol, include_private = false) #:nodoc:
      current_choice.respond_to?(symbol, include_private) || super
    end

    def safe_respond_to?(symbol, include_private = false) #:nodoc:
      orig_respond_to?(symbol, include_private)
    end

    def method_missing(symbol, *args, &block) #:nodoc:
      current_choice.__send__(symbol, *args, &block)
    end

    def do_read(io) #:nodoc:
      hook_before_do_read
      current_choice.do_read(io)
    end

    def do_write(io) #:nodoc:
      current_choice.do_write(io)
    end

    def do_num_bytes #:nodoc:
      current_choice.do_num_bytes
    end

    #---------------
    private

    def hook_before_do_read; end
    def hook_after_current_choice(*args); end

    def current_choice
      selection = eval_parameter(:selection)
      if selection.nil?
        raise IndexError, ":selection returned nil for #{debug_name}"
      end

      obj = get_or_instantiate_choice(selection)
      hook_after_current_choice(selection, obj)

      obj
    end

    def get_or_instantiate_choice(selection)
      @choices[selection] ||= instantiate_choice(selection)
    end

    def instantiate_choice(selection)
      prototype = get_parameter(:choices)[selection]
      if prototype.nil?
        raise IndexError, "selection '#{selection}' does not exist in :choices for #{debug_name}"
      end
      prototype.instantiate(nil, self)
    end

    def copy_previous_value(selection, obj)
      prev = get_previous_choice(selection)
      obj.assign(prev) unless prev.nil?
      remember_current_selection(selection)
    end

    def get_previous_choice(selection)
      if selection != @last_selection and @last_selection != nil
        @choices[@last_selection]
      else
        nil
      end
    end

    def remember_current_selection(selection)
      @last_selection = selection
    end
  end
end
