module Taro::Types::Shared::Pattern
  def pattern
    self.class.pattern
  end

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    attr_reader :pattern, :openapi_pattern

    def pattern=(regexp)
      openapi_type == :string ||
        raise(Taro::RuntimeError, 'pattern requires openapi_type :string')

      @pattern = regexp
      @openapi_pattern = Taro::Types::Shared::Pattern.to_es262(regexp)
    end
  end

  def self.to_es262(regexp)
    validate(regexp).source.gsub(
      /#{NOT_ESCAPED}\\[Ahz]/,
      { '\\A' => '^', '\\h' => '[0-9a-fA-F]', '\\z' => '$' }
    )
  end

  def self.validate(regexp)
    validate_no_flags(regexp)
    validate_not_empty(regexp)
    validate_no_advanced_syntax(regexp)
    regexp
  end

  def self.validate_no_flags(regexp)
    (flags = regexp.inspect[%r{/\w+\z}]) &&
      raise(Taro::ArgumentError, "pattern flags (#{flags}) are not supported")
  end

  def self.validate_not_empty(regexp)
    regexp.source.empty? &&
      raise(Taro::ArgumentError, 'pattern cannot be empty')
  end

  def self.validate_no_advanced_syntax(regexp)
    return unless (match = regexp.source.match(ADVANCED_RUBY_REGEXP_SYNTAX_REGEXP))

    feature = match.named_captures.find { |k, v| break k if v }
    raise Taro::ArgumentError, <<~MSG
      pattern uses non-JS syntax #{match} (#{feature}) at index #{match.begin(0)}
    MSG
  end

  NOT_ESCAPED = /(?<!\\)(?:\\\\)*\K/

  # This is not 100% accurate, e.g. /[?+]/ is a false positive, but it should be
  # good enough so we don't need regexp_parser or js_regex as a dependency.
  ADVANCED_RUBY_REGEXP_SYNTAX_REGEXP = /
    #{NOT_ESCAPED}
    (?:
        (?<a special group or lookaround> \(\?[^:] )
      | (?<a Ruby-specific escape> \\[a-zA-Z&&[^bBdDsSwWAzfhnrv]] )
      | (?<an advanced quantifier> [?*+}][?+] )
      | (?<a nested set> \[[^\]]*(?<!\\)\[ )
      | (?<a set intersection> && )
    )
  /x
end
