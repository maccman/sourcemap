module SourceMaps
  class Offset
    include Comparable

    def initialize(line, column)
      @line, @column = line, column
    end

    attr_reader :line, :column

    def +(other)
      case other
      when Offset
        Offset.new(self.line + other.line, self.column + other.column)
      when Integer
        Offset.new(self.line + other, self.column)
      else
        raise ArgumentError, "can't convert #{other} into #{self.class}"
      end
    end

    def <=>(other)
      case other
      when Offset
        diff = self.line - other.line
        diff.zero? ? self.column - other.column : diff
      else
        raise ArgumentError, "can't convert #{other.class} into #{self.class}"
      end
    end

    def to_s
      "#{line}:#{column}"
    end

    def inspect
      "#<#{self.class} line=#{line}, column=#{column}>"
    end
  end
end