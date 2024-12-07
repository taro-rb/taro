module Taro::Types::Shared::Name
  def define_name(name)
    instance_eval(<<~RUBY, __FILE__, __LINE__ + 1)
      def name
        #{name.inspect}
      end
      alias to_s name

      def inspect
        "#<#{name}>"
      end
    RUBY
  end
end
