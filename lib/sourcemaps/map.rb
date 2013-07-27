require 'sprockets/vlq'

module SourceMaps
  class Map
    def self.from_json(json)
      from_hash JSON.parse(json)
    end

    def self.from_hash(hash)
      new({
        :version  => hash['version'],
        :filename => hash['file'],
        :mappings => Mappings.from_vlq(hash['mappings'], hash['sources'], hash['names'])
      })
    end

    def initialize(hash = {})
      @version  = hash[:version] || 3
      @filename = hash[:filename]
      @mappings = hash[:mappings]
    end

    attr_reader :version

    attr_reader :filename

    attr_reader :mappings

    def line_count
      mappings.line_count
    end

    def sources
      mappings.sources
    end

    def names
      mappings.names
    end

    def as_json
      {
        "version"   => version,
        "file"      => filename,
        "lineCount" => line_count,
        "mappings"  => mappings.to_s,
        "sources"   => sources,
        "names"     => names
      }
    end
  end
end