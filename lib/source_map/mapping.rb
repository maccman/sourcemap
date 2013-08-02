require 'source_map/offset'

module SourceMap
  class Mapping
    def initialize(source, generated, original, name = nil)
      @source, @generated, @original = source, Offset.new(generated), Offset.new(original)
      @name = name
    end

    attr_reader :generated, :original, :source, :name

    def inspect
      "#<#{self.class} generated=#{generated}, original=#{original}, source=#{source}, name=#{name}>"
    end
  end
end
