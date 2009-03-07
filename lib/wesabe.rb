$:.unshift(File.dirname(__FILE__))

begin
  require 'rubygems'
rescue LoadError
  # no rubygems, just keep going
end

require 'hpricot'
require 'net/https'
require 'yaml'
require 'time'

# Provides an object-oriented interface to the Wesabe API.
class Wesabe
  attr_accessor :username, :password

  VERSION = "0.0.1"

  # Initializes access to the Wesabe API with a certain user. All requests
  # will be made in the context of this user.
  #
  # @param [String] username
  #   The username of an active Wesabe user.
  #
  # @param [String] password
  #   The password of an active Wesabe user.
  def initialize(username, password)
    self.username = username
    self.password = password
  end

  # Fetches the user's accounts list from Wesabe or, if the list was already
  # fetched, returns the cached result.
  #
  #   pp wesabe.accounts
  #   [#<Wesabe::Account:0x106105c
  #     @balance=-393.42,
  #     @currency=
  #      #<Wesabe::Currency:0x104fdc0
  #       @decimal_places=2,
  #       @delimiter=",",
  #       @separator=".",
  #       @symbol="$">,
  #     @financial_institution=
  #      #<Wesabe::FinancialInstitution:0x104b054
  #       @homepage_url=nil,
  #       @id="us-003383",
  #       @login_url=nil,
  #       @name="American Express Card">,
  #     @id=4,
  #     @name="Amex Blue">]
  #
  # @return [Array<Wesabe::Account>]
  #   A list of the user's active accounts.
  def accounts
    @accounts ||= load_accounts
  end

  # Returns an account with the given id or +nil+ if the account is not found.
  #
  #   wesabe.account(4).name # => "Amex Blue"
  #
  # @param [#to_s] id
  #   Something whose +to_s+ result matches the +to_s+ result of the account id.
  #
  # @return [Wesabe::Account, nil]
  #   The account whose user-scoped id is +id+ or +nil+ if there is no account
  #   with that +id+.
  def account(id)
    accounts.find {|a| a.id.to_s == id.to_s}
  end

  # Fetches the user's accounts list from Wesabe or, if the list was already
  # fetched, returns the cached result.
  #
  #   pp wesabe.credentials
  #   [#<Wesabe::Credential:0x10ae870
  #     @accounts=[],
  #     @financial_institution=
  #      #<Wesabe::FinancialInstitution:0x1091928
  #       @homepage_url=nil,
  #       @id="us-003383",
  #       @login_url=nil,
  #       @name="American Express Card">,
  #     @id=3>]
  #
  # @return [Array<Wesabe::Account>]
  #   A list of the user's active accounts.
  def credentials
    @credentials ||= load_credentials
  end

  # Fetches the user's targets list from Wesabe or, if the list was already
  # fetched, returns the cached result.
  def targets
    @targets ||= load_targets
  end
  
  # Fetchs all the user's txactions within the provided range. This does not
  # current cache the result set so be careful! if dates aren't provided it
  # will default to txactions for the last thirty days.
  # 
  def txactions_for (sdate, edate)
    return load_txactions(sdate, edate)
  end
  
  def tag_stats (txactions)
    tag_stats = Wesabe::Stats::Tags.new
    tag_stats.filter('transfer')
    txactions.each { |txn| txn.tags.each { |tag| tag_stats.add tag, txn.amount } }
    return tag_stats
  end
  
  # Executes a request via POST with the initial username and password.
  #
  # @see Wesabe::Request::execute
  def post(options)
    Request.execute({:method => :post, :username => username, :password => password}.merge(options))
  end

  # Executes a request via GET with the initial username and password.
  #
  # @see Wesabe::Request::execute
  def get(options)
    Request.execute({:method => :get, :username => username, :password => password}.merge(options))
  end

  def inspect
    "#<#{self.class.name} username=#{username.inspect} password=#{password.gsub(/./, '*').inspect} url=#{Wesabe::Request.base_url.inspect}>"
  end

  private

  def load_accounts
    process_accounts( Hpricot::XML( get(:url => '/accounts.xml') ) )
  end

  def process_accounts(xml)
    associate((xml / :accounts / :account).map do |element|
      Account.from_xml(element)
    end)
  end

  def load_credentials
    process_credentials( Hpricot::XML( get(:url => '/credentials.xml') ) )
  end

  def process_credentials(xml)
    associate((xml / :credentials / :credential).map do |element|
      Credential.from_xml(element)
    end)
  end

  def load_targets
    process_targets( Hpricot::XML( get(:url => '/targets.xml') ) )
  end

  def process_targets(xml)
    associate((xml / :targets / :target).map do |element|
      Target.from_xml(element)
    end)
  end

  def load_txactions (sdate, edate)
    ds          = Wesabe::DataSource::Txactions.new
    ds.wesabe   = self
    ds.sdate    = sdate
    ds.edate    = edate
    ds.accounts = accounts
    ds.load
    
    return ds.txactions
  end

  def associate(what)
    Wesabe::Util.all_or_one(what) {|obj| obj.wesabe = self}
  end
end

require 'wesabe/util'
require 'wesabe/request'
require 'wesabe/base_model'
require 'wesabe/account'
require 'wesabe/upload'
require 'wesabe/financial_institution'
require 'wesabe/currency'
require 'wesabe/credential'
require 'wesabe/job'
require 'wesabe/target'
require 'wesabe/txaction'
require 'wesabe/data_source/txactions'
require 'wesabe/stats/tags'
