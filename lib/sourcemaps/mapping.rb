require 'sourcemaps/offset'

module SourceMaps
  class Mapping
    include Comparable

    def initialize(source, generated, original, name = nil)
      @source, @generated, @original = source, generated, original
      @name = name
    end

    attr_reader :generated, :original, :source, :name

    def <=>(other)
      case other
      when Mapping
        self.generated <=> other.generated
      when Offset
        self.generated <=> other
      else
        raise ArgumentError, "can't convert #{other.class} into #{self.class}"
      end
    end

    def inspect
      "#<#{self.class} generated=#{generated}, original=#{original}, source=#{source}, name=#{name}>"
    end
  end
end
