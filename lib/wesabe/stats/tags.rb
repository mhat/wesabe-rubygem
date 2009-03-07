module Wesabe::Stats
  class Tag
    attr_reader   :name
    attr_accessor :total
    attr_accessor :count
    
    def initialize(name)
      @name  = name
      @total = 0.0
      @count = 0
    end
  end
  
  class Tags
    include Enumerable
    
    def initialize
      @tags    = Hash.new
      @filters = Hash.new
    end
    
    def filter(tag_name)
      @filters[tag_name] = true
    end
    
    def add(tag_name, amount=0.0)
      ## ignore filtered tags whole-sale, like they don't even exist!
      return if @filters.has_key?(tag_name)
      
      tag = @tags.has_key?(tag_name) \
        ? @tags[tag_name] \
        : @tags[tag_name] = Wesabe::Stats::Tag.new(tag_name)
      
      tag.count += 1
      tag.total += amount.to_f
    end
    
    def each(&block)
      @tags.each_value(&block)
    end
    
    def count
      return @tags.size
    end
    
    def total
      return inject(0.0) { |total,tag| total += tag.total }
    end
    
  end
end