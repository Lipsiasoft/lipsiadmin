module Lipsiadmin
  module Utils
    module Literal
      # Returns an object whose <tt>to_json</tt> evaluates to +code+. Use this to pass a literal JavaScript 
      # expression as an argument to another JavaScriptGenerator method.
      #
      def to_literal
        ActiveSupport::JSON::Variable.new(self.to_s)
      end
      alias_method :to_l, :to_literal
    end
  end
end