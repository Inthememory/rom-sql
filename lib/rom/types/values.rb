# frozen_string_literal: true

require 'rom/sql/types'

module ROM
  module Types
    module Values
      class TreePath < ::Struct.new(:value, :separator) # rubocop:disable Style/StructInheritance
        # @api public
        def self.new(value, separator = '.')
          super
        end

        # @api public
        def to_s
          value
        end
        alias_method :to_str, :to_s
      end
    end
  end
end
