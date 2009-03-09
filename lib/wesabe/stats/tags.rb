module Wesabe::Stats
  class Tag
    attr_reader   :name
    attr_reader   :container
    attr_accessor :txactions
    
    def initialize(name,container)
      @name      = name
      @container = container
      @txactions = []
    end
    
    def count 
      return @txactions.size
    end
    
    def total
      return @txactions.inject(0.0) { |total, txn| total += txn.amount }
    end
  end
  
  class Tags
    include Enumerable
    
    def initialize
      @tag_klass = Wesabe::Stats::Tag;
      @tags      = Hash.new
      @filters   = Hash.new
    end
    
    def filter(tag_name)
      @filters[tag_name] = true
    end
    
    def add (txaction)
      txaction.tags.each do |tag_name|
        
        case @tags.has_key?(tag_name)
          when true: tag = @tags[tag_name]
          else       tag = @tags[tag_name] = @tag_klass.new(tag_name,self)
        end
        
        tag.txactions << txaction
      end
    end
    
    def each(&block)
      @tags.each_value do |tag|
        unless @filters.has_key? tag.name 
          block.call(tag)
        end
      end
    end
    
    def count
      return inject(0)   { |count,tag| count += tag.count }
    end
    
    def total
      return inject(0.0) { |total,tag| total += tag.total }
    end
    
  end
end