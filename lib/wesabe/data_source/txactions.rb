module Wesabe::DataSource
  
  class LockedError < StandardError
  end
  
  class Txactions
    
    attr_reader :accounts
    attr_reader :txactions
    attr_reader :sdate
    attr_reader :edate
    attr_reader :wesabe
    
    def initialize
      @locked    = false
      @accounts  = []
      @txactions = []
      @sdate     = nil
      @edate     = nil
      @wesabe    = nil
    end
    
    def locked? 
      return @locked
    end
    
    def wesabe= (wesabe)
      raise LockedError if locked?
      @wesabe = wesabe
    end
    
    def sdate= (dt)
      raise LockedError if locked?
      @sdate = Time.parse(dt)
    end
    alias :start_date :sdate
    
    def edate= (dt)
      raise LockedError if locked?
      @edate = Time.parse(dt)
    end
    alias :end_date :edate
    
    def accounts= (accts)
      raise LockedError if locked?
      @accounts = accts.select { |acct| acct.class == Wesabe::Account }
    end
    
    def since (dt)
      return range(dt, Time.now)
    end
    
    def range (sdate, edate)
      if (! locked?)
        sdate = Time.parse(sdate)
        edate = Time.parse(edate)
      end
      return [@sdate, @edate]
    end
    
    def load
      ## FIXME: should add some validation code to make sure the dates are
      ## (a) defined and (b) sdate < edate. it would also be good to make 
      ## sure accounts is non-empty/zero.
      sd      = sdate.strftime("%Y%m%d")
      ed      = edate.strftime("%Y%m%d")
      @locked = true
      
      @accounts.each do |account|
        ## be nice to the wesabe api service, let's not hit it too fast
        sleep(0.5)
        @txactions.concat(process(Hpricot::XML(wesabe.get(
          :url => "/accounts/#{account.id}.xml?start_date=#{sd}&end_date=#{ed}"
        ))))
      end
    end
    
    private
    def associate(what)
      Wesabe::Util.all_or_one(what) {|obj| obj.wesabe = wesabe }
    end
        
    def process(xml)
      return associate((xml / :txactions / :txaction ).map do |element|
        Wesabe::Txaction.from_xml(element)
      end)
    end
  end
end